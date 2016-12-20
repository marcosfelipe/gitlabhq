require 'spec_helper'

feature 'Groups > Pipeline Quota', feature: true do
  let(:user) { create(:user) }
  let(:group) { create(:group) }
  let!(:project) { create(:project, namespace: group, shared_runners_enabled: true) }

  before do
    group.add_owner(user)
    login_with(user)
  end

  context 'with no quota' do
    let(:group) { create(:group, :with_build_minutes) }

    it 'shows correct ratio and status' do
      visit_pipeline_quota_page

      page.within('.pipeline-quota') do
        expect(page).to have_content("400 / Unlimited minutes")
        expect(page).to have_selector('.progress-bar-success')
      end
    end
  end

  context 'with no projects using shared runners' do
    let(:group) { create(:group, :with_not_used_build_minutes_limit) }
    let!(:project) { create(:project, namespace: group, shared_runners_enabled: false) }

    it 'shows correct ratio and status' do
      visit_pipeline_quota_page

      page.within('.pipeline-quota') do
        expect(page).to have_content("300 / Unlimited minutes")
        expect(page).to have_selector('.progress-bar-success')
      end
    end
  end

  context 'minutes under quota' do
    let(:group) { create(:group, :with_not_used_build_minutes_limit) }

    it 'shows correct ratio and status' do
      visit_pipeline_quota_page

      page.within('.pipeline-quota') do
        expect(page).to have_content("300 / 500 minutes")
        expect(page).to have_content("60% used")
        expect(page).to have_selector('.progress-bar-success')
      end
    end
  end

  context 'minutes over quota' do
    let(:group) { create(:group, :with_used_build_minutes_limit) }

    it 'shows correct ratio and status' do
      visit_pipeline_quota_page

      page.within('.pipeline-quota') do
        expect(page).to have_content("1000 / 500 minutes")
        expect(page).to have_content("200% used")
        expect(page).to have_selector('.progress-bar-danger')
      end
    end
  end

  def visit_pipeline_quota_page
    visit group_pipeline_quota_path(group)
  end
end
