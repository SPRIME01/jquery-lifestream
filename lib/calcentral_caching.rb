module CalcentralCaching

  extend self

  def setup_cache_store
    Calcentral::Application.configure do
      case Settings.cache.store
        when "memcached"
          Rails.logger.info "Rails.cache_store is memcached (dalli_store); cache log level = #{Settings.cache.log_level}"
          config.cache_store = ActiveSupport::Cache.lookup_store(
            :dalli_store,
            *Settings.cache.servers,
            {
              :expires_in => Settings.cache.maximum_expires_in,
              :namespace => ServerRuntime.get_settings["git_commit"],
              :race_condition_ttl => Settings.cache.race_condition_ttl
            }
          )
        else
          Rails.logger.info "Rails.cache_store is memory_store; cache log level = #{Settings.cache.log_level}"
          config.cache_store = ActiveSupport::Cache.lookup_store(
            :memory_store,
            :size => 16.megabytes,
            :namespace => ServerRuntime.get_settings["git_commit"])
      end

      config.cache_store.logger = Logger.new("#{CalcentralLogging.log_root}/cache_#{Time.now.strftime('%Y-%m-%d')}.log")
      config.cache_store.logger.level = Settings.cache.log_level

    end
  end
end