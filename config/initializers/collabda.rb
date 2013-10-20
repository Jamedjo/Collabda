if Rails.env.development?
  collabda_reloader = ActiveSupport::FileUpdateChecker.new(Dir.glob("config/*.y*ml")) do
    Collabda.rebuild_collections
  end
  ActionDispatch::Callbacks.before do
    collabda_reloader.execute_if_updated
  end
end