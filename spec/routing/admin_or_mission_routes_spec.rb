require 'spec_helper'

describe 'router' do
  it 'routes admin mode forms' do
    { :get => '/en/admin/forms' }.should route_to(
      :controller => 'forms', :action => 'index', :locale => 'en', :mode => 'admin')
  end

  it 'routes admin mode forms even with mission_id' do
    # Note this seems wrong but will be caught after routing by the ApplicationController
    { :get => '/en/admin/mission123/forms' }.should route_to(
      :controller => 'forms', :action => 'index', :locale => 'en', :mode => 'admin', :mission_id => 'mission123')
  end

  it 'routes mission mode forms' do
    { :get => '/en/m/mission123/forms' }.should route_to(
      :controller => 'forms', :action => 'index', :locale => 'en', :mode => 'm', :mission_id => 'mission123')
  end

  it 'rejects forms with no mode' do
    { :get => '/en/forms' }.should_not be_routable
  end

  it 'routes options suggest in admin mode' do
    { :get => '/en/admin/options/suggest' }.should route_to(
      :controller => 'options', :action => 'suggest', :locale => 'en', :mode => 'admin')
  end

  it 'routes options suggest in mission mode' do
    { :get => '/en/m/mission123/options/suggest' }.should route_to(
      :controller => 'options', :action => 'suggest', :locale => 'en', :mode => 'm', :mission_id => 'mission123')
  end
end
