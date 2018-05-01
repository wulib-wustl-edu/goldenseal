# Generated via
#  `rails generate curation_concerns:work Document`

class CurationConcerns::DocumentsController < ApplicationController
  include CurationConcerns::CurationConcernController
  include CustomMetadata

  set_curation_concern_type Document

  def show_presenter
    WorkShowPresenter
  end
end
