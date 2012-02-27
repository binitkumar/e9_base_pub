E9 Rails 3 CMS Platform
=======================


Setup
-----

1.  Generate a new rails project
        
        rails create foo

2.  Init a git repository:

        cd foo && git init

3.  Edit the README and commit:

        echo "whatever" > README && git ci -a -m "initial commit"

4.  Add the gem as a submodule (currently the engine branch):

        git submodule add -b engine git@github.com:e9digital/e9-rails3.git vendor/e9_base

5.  Configure your database as desired in config/database.yml and add the necessary gem(s) to Gemfile,
    and create your database.

6.  Add the e9_base gem to the Gemfile:

        echo "gem 'e9_base', :path => 'vendor/e9_base'" >> Gemfile

7.  Run the e9_base generator, which will add all the files you need and remove ones you don't:

        rails g e9_base

8.  Add the following line to config/initializers/session_store.rb, replacing '_foo_session' with your session key:

        Rails.application.config.middleware.insert_before(:"ActionDispatch::Session::CookieStore", FlashSessionCookieMiddleware, '_foo_session')

8.  Migrate the database:

        rake db:migrate

9.  Add a symlink to the vendor directory from public.  This addresses an issue Jammit has, that all javascripts
    it compiles need to be public facing, while in our case we want most the files to remain with the gem and shared.
    In production this symlink is unnecessary (and won't exist) as the javascripts will be compiled into minified
    files hosted at public/assets.

        ln -s ../vendor public/vendor

        
At this point, the basic system should be ready to run. 


Components
----------

### config/*_settings.yml

These files are for settings defaults, and should be edited to reflect your application, containing 
such settings as 'site_name', etc., and additionally you can setup things like facebook, twitter, etc. here.


### config/assets.yml

This defines the javascripts to be included into the compiled files.  Most the scripts refer to files 
in app/javascripts within the plugin.  If desired you could copy them down and edit them, but be sure to change
where they're sourced here.  This would also be the place to add js custom to the application.


### public/javascripts/*

Your public javascripts, as typical with any rails app, with some additions.

application.js was seeded here by generator, which is a copy of the original plugin version.  This is the 
only system javascript file that is copied over from the gem, and can be edited to suit your application.

The other files here were copied over because they are loaded on demand and not compiled like the rest
of the javascript in the application.

Of note is tiny_mce folder, which contains 2 files which **must** be edited for your app,
tiny_mce/plugins/(filemanager|imagemanager)/config.php.  Both files must be edited to point to the absolute path
of the shared directory in your deployment, (e.g. /srv/apps/foo/shared):

	  $mc(Image|File)ManagerConfig['preview.wwwroot']         = '#PATH_TO_YOUR_SHARED_DIR#/';
	  $mc(Image|File)FileManagerConfig['filesystem.rootpath'] = '#PATH_TO_YOUR_SHARED_DIR#/uploads/files';


### app/stylesheets

All the sass/scss files that make up your styles.  Edit these for your app.


### db/seeds

Seed files for your app.  Edit these to seed your appropriate data, or add your own files and make sure they're
loaded by db/seeds.rb

        
TODO
----

- create rake task to copy pending base migrations (probably involves copying over all migrations from base over the original schema stamp, ignoring files that already exist?)
- add the line that loads the FlashMiddleware automatically on e9_base generate
