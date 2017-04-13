namespace :custom do
  desc 'Clear Rails cache'
  task :clear_cache do
    on roles(:app) do
      within "#{current_path}" do
        with rails_env: "#{fetch(:stage)}" do
          execute :rake, 'tmp:clear'
        end
      end
    end
  end
end
