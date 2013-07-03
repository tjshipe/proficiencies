get '/' do
  # render home page
  @users = User.all

  erb :index
end

#----------- SESSIONS -----------

get '/sessions/new' do
  # render sign-in page
  @email = nil
  erb :sign_in
end

post '/sessions' do
  # sign-in
  @email = params[:email]
  user = User.authenticate(@email, params[:password])
  if user
    # successfully authenticated; set up session and redirect
    session[:user_id] = user.id
    redirect '/'
  else
    # an error occurred, re-render the sign-in form, displaying an error
    @error = "Invalid email or password."
    erb :sign_in
  end
end

delete '/sessions/:id' do
  # sign-out -- invoked via AJAX
  return 401 unless params[:id].to_i == session[:user_id].to_i
  session.clear
  200
end

get '/edit_proficiencies/:id' do
  @user = User.find(session[:user_id])
  @prof = @user.proficiencies
  erb :proficiency
end

post '/add_prof' do
  user = User.find(session[:user_id])
  
  skill = Skill.find_or_initialize_by_name(params[:prof][:skill])
  skill.context = 'technical'
  skill.save
  
  bob = user.proficiencies.new(years: params[:prof][:years], formal: params[:prof][:formal])
  bob.skill_id = skill.id
  bob.save
  
  redirect "/edit_proficiencies/#{user.id}"
end

get '/delete_proficiency/:id' do
  user = User.find(session[:user_id])
  proficiency = user.proficiencies.find(params[:id])
  proficiency.destroy

  redirect "/edit_proficiencies/#{user.id}"
end

#----------- USERS -----------

get '/users/new' do
  # render sign-up page
  @user = User.new
  erb :sign_up
end

post '/users' do
  # sign-up
  @user = User.new params[:user]
  if @user.save
    # successfully created new account; set up the session and redirect
    session[:user_id] = @user.id
    redirect '/'
  else
    # an error occurred, re-render the sign-up form, displaying errors
    erb :sign_up
  end
end
