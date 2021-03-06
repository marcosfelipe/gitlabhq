# frozen_string_literal: true

module QA
  context 'Plan' do
    describe 'Close issue' do
      let(:issue) do
        Resource::Issue.fabricate_via_api!
      end

      let(:issue_id) { issue.api_response[:iid] }

      before do
        Flow::Login.sign_in

        # Initial commit should be pushed because
        # the very first commit to the project doesn't close the issue
        # https://gitlab.com/gitlab-org/gitlab-foss/issues/38965
        push_commit('Initial commit')
      end

      it 'closes an issue by pushing a commit' do
        push_commit("Closes ##{issue_id}", false)

        issue.visit!

        Page::Project::Issue::Show.perform do |show|
          reopen_issue_button_visible = show.wait_until(reload: true) do
            show.has_element?(:reopen_issue_button, wait: 1.0)
          end
          expect(reopen_issue_button_visible).to be_truthy
        end
      end

      def push_commit(commit_message, new_branch = true)
        Resource::Repository::ProjectPush.fabricate! do |push|
          push.commit_message = commit_message
          push.new_branch = new_branch
          push.file_content = commit_message
          push.project = issue.project
        end
      end
    end
  end
end
