# frozen_string_literal: true

class RevisionsController < ApplicationController
  before_action :find_user, :find_publication, :find_post
  layout false

  def create
    blob = publication.git_provider.adapter.create_or_update_blob(
      fullname: publication.repo_fullname,
      path: @post.path || params[:blob_path],
      content: Base64.encode64(blob_content),
      message: message.presence,
      sha: post.revisions&.first&.blob_sha,
      committer: GitConfig.new.committer,
      author: {
        name: author.name,
        email: author.email,
        date: Date.today
      }
    )


    redirect_to edit_user_publication_post_path(@user, @publication, revision)
  end

  private

  def find_blob
    @post = @publication.repository.blob(path: params[:blob_path])
  end

  def find_publication
    @publication = @user.publications.friendly.find(params[:publication_permalink])
  end

  def find_user
    @user = User.friendly.find(params[:user_username])
  end

  def revision_params
    params.require(:revision).permit(:message, :title, :summary, :body)
  end
end
