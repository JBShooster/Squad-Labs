require 'sinatra'
require 'better_errors'
require 'pg'
require 'pry'

configure :development do 
  use BetterErrors:: Middleware
  BetterErrors.application_root = __dir__
end

set :conn, PG.connect(dbname: 'squad_info')

before do
  @conn = settings.conn
end

#ROOT ROUTE
get '/' do
  redirect '/squads'
end

#INDEX
get '/squads' do
  squads = []
  @conn.exec("SELECT * FROM squads_table") do |result|
    result.each do |squad|
      squads << squad
    end
  end
  @squads = squads
  erb :index
end

#GET STUDENTS LIST
get '/squads/:squad_id/students' do
  students = []
  squad_id = params[:squad_id].to_i
  squad = @conn.exec("SELECT * FROM squads_table WHERE squad_id = $1", [squad_id])
  @conn.exec("SELECT * FROM students_table WHERE squad= $1", [squad_id]) do |result|
    result.each do |student|
      students << student
    end
  end
  @squad = squad[0]
  @students = students
  erb :students
end

#GET SQUAD NEW
get '/squads/new' do
  erb :squad_new
end

#GET STUDENT NEW
get '/squads/:squad_id/students/new' do
  id = params[:squad_id].to_i
  squad = @conn.exec("SELECT * FROM squads_table WHERE squad_id = $1", [id])
  @squad = squad[0]
  @squad_id = id
  erb :student_new
end

#GET SQUAD ID
get '/squads/:squad_id' do
  id = params[:squad_id].to_i
  squad = @conn.exec("SELECT * FROM squads_table WHERE squad_id = $1", [id])
  @squad = squad[0]
  erb :squad_id
end

#GET SQUAD EDIT
get '/squads/squad_edit/:squad_id' do
  id = params[:squad_id].to_i
  squad = @conn.exec("SELECT * FROM squads_table WHERE squad_id = $1", [id])
  @squad = squad[0]
  erb :squad_edit
end

#GET STUDENT EDIT
get '/squads/:squad_id/student_edit/:student_id' do
  id = params[:student_id].to_i
  student = @conn.exec("SELECT * FROM students_table WHERE student_id = $1", [id])
  @student = student[0]
  erb :student_edit
end


#POST NEW SQUAD
post '/squads' do
  @conn.exec("INSERT INTO squads_table (name, mascot) VALUES ($1, $2)", [params[:name], params[:mascot]])
  redirect'/squads'
end

#POST NEW STUDENT
post '/squads/:squad_id/students' do
  @conn.exec("INSERT INTO students_table (name, age, animal, squad) VALUES ($1, $2, $3, $4)", [params[:name], params[:age], params[:animal], params[:squad]])
  redirect'/squads'
end


#PUT SQUAD CHANGES
put '/squads/:squad_id/students' do
  id = params[:squad_id].to_i
  @conn.exec("UPDATE squads_table SET name = $1, mascot = $2 WHERE squad_id = $3", [params[:name], params[:mascot], id])
  redirect'/squads'
end

#PUT STUDENT CHANGES
put '/squads/:squad_id/students' do
  id = params[:student_id].to_i
  @conn.exec("UPDATE students_table SET name = $1, age = $2, animal = $3 WHERE student_id = $4", [params[:name], params[:age], params[:animal], id])
  redirect '/squads/:squad_id/students'
end

#DESTROY ROUTE
delete '/squads/:squad_id' do
  id = params[:squad_id].to_i
  @conn.exec("DELETE FROM squads_table WHERE squad_id=$1", [id])
  @conn.exec("DELETE FROM students_table WHERE squad=$1", [id])
  redirect'/squads'
end

