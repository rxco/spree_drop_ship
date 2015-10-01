module Spree
  module Api
    class UserSessionsController < Spree::Api::BaseController

      def create
        @user = Spree::User.find_by_email(params[:user][:email])
        if @user.nil?
          not_found
          return
        end
        if @user.present? && !@user.valid_password?(params[:user][:password])
          unauthorized
          return
        end
        @user = sign_in :spree_user, @user
        respond_with(@user, :status => 200, :default_template => :show)
      end

      def destroy
        sign_out @user
        respond_with('', :status => 204)
      end

    end
  end
end