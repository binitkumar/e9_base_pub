ActiveRecord::Observer.disable_observers

# NOTE it's important to reload this here because of environment loading issues and the nature of Config as a singleton
E9::Config.reload!
E9::Config[:debug_mode] = false
E9::Config.cache!
