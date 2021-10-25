class SignupsController < ApplicationController
  def email
    @user = User.new
  end

  def create
    @user = User.build_with_email(signup_params)

    if params['commit'] == 'Signup' && @user.save
      redirect_to signups_path, notice: t('.success')
    else
      filled_params = signup_params.delete_if { |key, value| value.blank? }
      @user.valid_attributes?(*filled_params.keys)

      respond_to do |format|
        format.html { render :email }
        format.turbo_stream { render turbo_stream: turbo_stream.replace(@user, partial: 'signups/form', locals: { user: @user }) }
      end
    end
  end

  private

  def signup_params
    params.require(:user).permit(:username, :email, :name)
  end
end
