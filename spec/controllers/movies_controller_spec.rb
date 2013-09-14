require 'spec_helper'

describe MoviesController do
	describe 'Add Director to Existing movie' do
		before :each do
      		#@movie = mock(Movie, :title => "Alien", :director => "Ridley Scott", :id => "1")
      		#Movie.stub(:find).with("1").and_return(@movie)
      		@movie = FactoryGirl.create(:movie, :id => "1", :title => "Alien", :director => nil) 
    	end

		it 'should call update_attributes with new attribute and redirect to show movie' do
			@fake_new_director = "Ridley Scott"
			Movie.stub(:find).and_return(@movie)
			@movie.should_receive(:update_attributes!).with("director" => @fake_new_director).and_return(true)
      		put :update, :id => @movie.id, :movie => {:director => @fake_new_director}
      		flash[:notice].should == "Alien was successfully updated."
      		response.should redirect_to(movie_path(@movie))
		end
	end

	describe 'Delete Movie' do
		before :each do
      		#@movie = mock(Movie, :title => "Alien", :director => "Ridley Scott", :id => "1")
      		#Movie.stub(:find).with("1").and_return(@movie) 
      		@movie = FactoryGirl.create(:movie, :id => "1", :title => "Alien", :director => "Ridley Scott") 
    	end

		it 'should call destroy and redirect to home' do
			@movie.stub!(:destroy).and_return(true)
      		put :destroy, {:id => @movie.id, :movie => @movie}
      		flash[:notice].should == "Movie 'Alien' deleted."
      		response.should redirect_to movies_path
		end
	end

	describe 'Searching for Movies by Director (happy path)' do
		before :each do
      		#@movie = mock(Movie, :title => "Alien", :director => "Ridley Scott", :id => "1")
      		#Movie.stub(:find).with("1").and_return(@movie) 
      		@movie = FactoryGirl.create(:movie, :id => "1", :title => "Alien", :director => "Ridley Scott") 
      		@fake_result = [mock('Movie'), mock('Movie')]
    	end

		it 'should route to movies with similar director' do
      		assert_routing(movie_director_path(@movie.id), {:controller => 'movies', :action => 'director', :movie_id => '1'}) 
		end

		it 'should find movies with the same director and render the new view' do
			Movie.should_receive(:same_director).with(@movie.director).and_return(@fake_result)
			get :director, :movie_id => @movie.id
			response.should render_template('director')
			assigns(:movies).should == @fake_result #check results
		end
	end

	describe 'Searching for Movies by Director (sad path)' do
		before :each do
      		#@movie = mock(Movie, :title => "Alien", :director => nil, :id => "1")
      		#Movie.stub(:find).with("1").and_return(@movie) 
      		@movie = FactoryGirl.create(:movie, :id => "1", :title => "Alien", :director => nil) 
    	end

		it 'should route to movies with similar director' do
      		assert_routing(movie_director_path(@movie.id), {:controller => 'movies', :action => 'director', :movie_id => '1'}) 
		end

		it 'should redirect_to home and flash with advice' do
			get :director, :movie_id => @movie.id
			response.should redirect_to(movies_path)
			flash[:notice].should == "'Alien' has no director info"
		end
	end
end