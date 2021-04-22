#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def init_db
  @db = SQLite3::Database.new 'blog.db'
  @db.results_as_hash = true
end

before do
  init_db
end

configure do
  init_db
  @db.execute 'CREATE TABLE IF NOT EXISTS Posts
  (
  id  INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  created_date  DATE,
  content TEXT
  )'

  @db.execute 'CREATE TABLE IF NOT EXISTS Comments
  (
  id  INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  post_id INTEGER,
  created_date  DATE,
  content TEXT
  )'
end

get '/' do
  @results = @db.execute 'select * from Posts order by id desc'

	erb :index
end

get '/new_post' do
  erb :new
end

post '/new_post' do
  content = params[:content]

  if content.length <= 0
    @error = 'Введите текст'
    return erb :new
  end

  @db.execute 'insert into Posts (content, created_date) values (?, datetime())', [content]

  redirect '/'
end

get '/details/:post_id' do
  post_id = params[:post_id]
  results = @db.execute 'select * from Posts where id = ?', [post_id]
  @row = results[0]
  @comments = @db.execute 'select * from Comments where post_id = ? order by id desc', [post_id]

  erb :details
end

post '/details/:post_id' do
  post_id = params[:post_id]
  content = params[:content]

  @db.execute 'insert into Comments (content, post_id, created_date) values (?, ?, datetime())', [content, post_id]

  redirect "/details/#{post_id}"
end
