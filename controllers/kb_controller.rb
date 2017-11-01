class KbController < ApplicationController
  include HighVoltage::StaticPage

  before_filter :authenticate_user!
  layout 'kb_layout'

end
