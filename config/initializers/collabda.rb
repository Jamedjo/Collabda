if Rails.env.development?
  yaml_reloader = ActiveSupport::FileUpdateChecker.new(Dir.glob("config/*.y*ml")) do
    YamlData.reload_all
  end
  ActionDispatch::Callbacks.before do
    yaml_reloader.execute_if_updated
  end
end