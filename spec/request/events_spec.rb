require 'spec_helper'

feature "Events", %q{
  In order to open call for papers
  As an user
  I want to add events
} do

  context "Viewing events" do
    scenario "While not logged in, I should be able to view events" do
      FactoryGirl.create(:event)
      visit '/events'
      page.should have_content 'GURU-SP'
      page.should have_no_content 'Sign in'
    end

  end

  context "Creating events" do
    scenario "I can create an event" do
      sign_in

      visit '/events'
      find('.create_button').click

      fill_in "Name", :with => 'GURU-SP'
      fill_in 'Description', :with => '50th meeting'
      fill_in 'Occurs at', :with => 1.day.from_now.strftime('%m/%d/%Y')

      find('input[type=image]').click

      page.should have_content "GURU-SP"
    end

    scenario "While not logged in, I should be able to view specific details about an event" do
      event = FactoryGirl.create(:event)

      visit '/events'

      click_link event.name

      page.should have_content 'GURU-SP'
      page.should have_no_content 'Sign in'
    end

    scenario "While registering, I can't register an event without a name" do
      sign_in

      visit '/events'
      find('.create_button').click


      fill_in 'Description', :with => '50th meeting'

      find('input[type=image]').click

      page.should have_content "Name can't be blank"
    end

    scenario "While registering, I can't register an event without a name" do
      sign_in

      visit '/events'
      find('.create_button').click

      fill_in 'Name', :with => 'GURU-SP'

      find('input[type=image]').click

      page.should have_content "Description can't be blank"
    end

    scenario "I should be able to see stats for an event" do
      FactoryGirl.create(:event)
      proposal = FactoryGirl.create(:proposal)
      FactoryGirl.create(:comment, :proposal => proposal)
      2.times { FactoryGirl.create(:vote, :proposal => proposal) }

      visit '/events'

      page.should have_content("1 proposal")
      page.should have_content("1 comment")
      page.should have_content("2 vote")
    end

    scenario "I should be able to see the events sorted by the date the events occur" do
      Timecop.freeze(2.days.ago)

      past_event = FactoryGirl.create(:event, :occurs_at => Time.now, :name => 'The Dinosaurs')
      todays_event = FactoryGirl.create(:event, :occurs_at => 2.days.from_now, :name => 'Groundhog Day')
      late_event = FactoryGirl.create(:event, :occurs_at => 10.days.from_now, :name => 'Late show')
      early_event = FactoryGirl.create(:event, :occurs_at => 5.day.from_now, :name => 'Good morning Vietnam')

      Timecop.return

      visit '/events'

      within(:xpath, "//div[@class='event_listed'][1]") do
        page.should have_content('Groundhog Day')
      end

      within(:xpath, "//div[@class='event_listed'][2]") do
        page.should have_content('Good morning Vietnam')
      end

      within(:xpath, "//div[@class='event_listed'][3]") do
        page.should have_content('Late show')
      end
    end

    scenario "I should be able to see warning if there are no events" do
      visit '/events'
      page.should have_content('There are no events yet. Be the first to create one!')
    end

    scenario "I should be able to go to the list of proposals clicking on the picture" do
      event = FactoryGirl.create(:event)
      visit event_path(event)

      within '#proposal' do
        page.should have_css("a[href*='#{event_path(event)}']")
      end

      page.should have_no_content "Administrative tools"
    end

    scenario "I should be able to see admin links if I am the the owner" do
      user = FactoryGirl.create(:user)
      sign_in_with(user)

      event = FactoryGirl.create(:event, :user => user)

      visit event_path(event)

      page.should have_content "Administrative tools"
      page.should have_content "Edit event"
      page.should have_content "Crop picture"
    end

    scenario "I should be able to edit an event" do
      user = FactoryGirl.create(:user)
      sign_in_with(user)

      event = FactoryGirl.create(:event, :user => user)

      visit edit_event_path(event)
      fill_in 'Occurs at', :with => '01/20/2011'

      find(".actions input").click
      page.should have_content "Event was successfully updated."
    end

    scenario "I should be able to create an event with an user registered thru omni auth" do
      pending "How?!"
      # user = User.new
      # user.authentications.build(:uid => '123', :provider => 'twitter')
      # user.save

      # sign_in_with(user)

      # visit '/events'
      # click_link 'New Event'
      # fill_in "Name", :with => 'GURU-SP'
      # fill_in 'Description', :with => '50th meeting'

      # click_button "Create Event"

      # page.should have_content "GURU-SP"
      # page.should have_content 'Event was successfully created.'
    end
  end
end
