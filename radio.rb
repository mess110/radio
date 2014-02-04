require 'sinatra'
require 'sinatra/reloader' if development?
require 'haml'

def run_cmd cmd
  Process.detach(fork{ exec "#{cmd} &"})
end

helpers do
  def playing?
    !`ps -e | grep mpg321`.empty?
  end
end

get '/' do
  @stations = [['Radio Cluj', 'http://89.238.227.6:8384']]
  haml :index
end

post '/play' do
  run_cmd "killall -9 mpg321"
  run_cmd "mpg321 #{params[:url]}"
  redirect '/'
end

post '/stop' do
  run_cmd "killall -9 mpg321"
  redirect '/'
end

__END__

@@ layout
%html
  %head
    %title radio
  %body
    = yield

@@ index
- if playing?
  %form{:action => '/stop', :method => 'POST'}
    %input{:type => 'submit', :value => 'stop'}
%form{:action => '/play', :method => 'POST'}
  %input{:type => 'text', :name => 'url'}
  %input{:type => 'submit', :value => 'play'}
%ul
  - @stations.each do |station|
    %li
      %form{:action => '/play', :method => 'POST'}
        = station[0]
        %input{:type => 'hidden', :name => 'url', :value => station[1]}
        %input{:type => 'submit', :value => 'play'}
        = station[1]
