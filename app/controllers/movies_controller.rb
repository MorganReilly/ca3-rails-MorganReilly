class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    # pull out all ratings from model
    @all_ratings = Movie.all_ratings
    # Check some or all, can't be none checked
    @selected_ratings = (params[:ratings] || Hash[@all_ratings.product([1])]).keys

    ensure_session_consistency
    ensure_params_consistency

    # CSS highlighting on titles
    @header_classes = {'title': '', 'release_date': ''}
    @header_classes[params[:sort]] = 'hilite'   

    @movies = Movie.where(rating: @selected_ratings).order(params[:sort])
  end

  def ensure_session_consistency
    # Session cookie implementation for ratings and sort
    session[:ratings] = params[:ratings] if params[:ratings] and (session[:ratings].nil? or (session[:rating] != params[:ratings]))
    session[:sort] = params[:sort] if params[:sort] and (session[:sort].nil? or (session[:sort] != params[:sort]))
  end
  
  def ensure_params_consistency
    return unless (session[:ratings] and params[:ratings].nil?) or (session[:sort] and params[:sort].nil?)
    # http redirect
    redirect_to movies_path(ratings: session[:ratings], sort: session[:sort]) and return
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
