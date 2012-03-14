# NOTE this was an attempt to skip Jammit in production, as we pregenerate
# assets before deployment.  Ran into an issue where the Jammit routes weren't
# generated in production and put this on hold as a quick fix.  Jammit is 
# required in the e9_base engine.
#
# if ENV['USE_JAMMIT_ASSETS'] || !Rails.env.development?
#   module JammitFallback
#     #
#     # Catch jammit javascript includes to simply return the precompiled
#     # assets.
#     #
#     # Note that this is *far* from complete and only functional because
#     # of the limited use of Jammit.  E.g. this doesn't cover stylesheets,
#     # and assumes the assets directory is "/assets"
#     #
#     def include_javascripts(*files)
#       javascript_include_tag(*files.map {|f| "/assets/#{f}" })
#     end
#   end

#   ActiveSupport.on_load(:action_controller) do
#     ActionController::Base.send(:helper, JammitFallback)
#   end
# else
#   require 'jammit'
# end
