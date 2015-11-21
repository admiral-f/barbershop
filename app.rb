require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'pony'

configure do
  enable :sessions
end

helpers do
  def username
    session[:identity] ? session[:identity] : 'Hello stranger'
  end
end

def sign_up
  @name = params[:enter_name]
  @phone = params[:phone]
  @visit_day = params[:visit_day]
  @visit_time = params[:visit_time]
  @barber = params[:barber]
  @color = params[:color]

  hh={:enter_name=> "Please, enter your name", :phone=>"Please, enter your phone number"}
  
  @error=hh.select {|key,_| params[key]==""}.values.join("; ")

  
  
  if @error==''
    f1=File.open 'public/user.txt','a'
    f1.write "User: <b>#{@name}</b></br> \n\tPhone: #{@phone}\n\tVisit day: #{@visit_day}\n\tVisit time: #{@visit_time}\n\tBarber: #{@barber}\n\tHair color: #{@color}</br>\n\n"
    f1.close
    @error = "#{@name}! We are waiting your at #{@visit_day} #{@visit_time}"
  end
  
  
end

before '/secure/*' do
  unless session[:identity]
    session[:previous_url] = request.path
    @error = 'Sorry, you need to be logged in to visit ' + request.path
    halt erb(:login_form)
  end
end

get '/' do
  erb :index
end

get '/login/form' do
  erb :login_form
end

post '/login/attempt' do
  session[:identity] = params['username']
  password=params['password']
  if session[:identity]=='admin' && password=='secret'
    #where_user_came_from = session[:previous_url] || '/'
    #redirect to where_user_came_from
    erb :index
  elsif session[:identity]=='alex' && password=='secret'
    #where_user_came_from = session[:previous_url] || '/'
    #redirect to where_user_came_from
    erb :account
  else
    @error="wrong username or password"
    session[:identity]='Hello stranger'
    erb :login_form
  end 

end

get '/logout' do
  session.delete(:identity)
  erb "<div class='alert alert-message'>Logged out</div>"
end

get '/secure/place' do
  if session[:identity]=='admin'
    @views=File.read('public/user.txt')
    erb :account
    #erb 'This is a secret place that only <%=session[:identity]%> has access to!'
  end 
end

get '/about' do
  erb :about
end

get '/visit' do
  erb :visit
end

get '/contacts' do
  erb :contacts
end

post '/contacts' do
  @name= params[:name]
  @email = params[:email]
  @text = params[:text]
  hh={:name=> "Please, enter your name", :email=>"Please, enter your phone Email", :text=>"Enter your text-message"}
  @error=hh.select {|key,_| params[key]==""}.values.join("; ")
  if @error==''
    f=File.open 'public/contacts.txt','a'
    f.write "User: #{@name}, Email: #{@email}, \nText: #{@text}.\n\n"
    f.close
    Pony.mail(
      :to => "admiral-f@yandex.ru",
      :from => "admiral-f@yandex.ru",
      :subject => params[:name] + " has contacted you",
      :body => params[:text],
      :via => :smtp,
      :via_options => { 
        :address              => 'smtp.yandex.ru', 
        :port                 => '25', 
        :enable_starttls_auto => true, 
        :user_name            => 'admiral-f', 
        :password             => 'kalinin1987', 
        :authentication       => :plain
    })
    @error = 'Your message send'
  end  
  erb :contacts
end

post '/visit' do
  sign_up
  erb :visit
end

post '/' do
  sign_up
  erb :index
end