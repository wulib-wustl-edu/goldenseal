class ApplicationController < ActionController::Base
  before_action :fake_sign_in
  before_action :set_default_url_options

  def fake_sign_in
    if Rails.env.development? && ENV['SKIP_LDAP']
      sign_in(:user, User.first)
    end
  end

  def set_default_url_options
    ActionMailer::Base.default_url_options = {:host => request.host_with_port}
    Rails.application.routes.default_url_options = {
      host: request.host_with_port,
      protocol: request.protocol
    }
  end

  rescue_from DeviseLdapAuthenticatable::LdapException do |exception|
    render text: exception, status: 500
  end
  helper Openseadragon::OpenseadragonHelper
  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  include Spotlight::Controller


  # Adds CurationConcerns behaviors to the application controller.
  include Hydra::Controller::ControllerBehavior
  include CurationConcerns::ApplicationControllerBehavior
  include CurationConcerns::ThemedLayoutController

  include Hydra::Controller::IpBasedAbility

  with_themed_layout '1_column'

  # FIXME: move to curation_concerns#325
  rescue_from ActiveFedora::ObjectNotFoundError do |_exception|
    render file: "#{Rails.root}/public/404.html", format: :html, status: :not_found, layout: false
  end

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
end
