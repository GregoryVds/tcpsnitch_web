namespace :custom do
  desc 'Seed statistics and statistic categories in database'
  task :seed_stats do
    on roles(:app) do
      within "#{current_path}" do
        with rails_env: "#{fetch(:stage)}" do
          execute :rake, 'db:seed'
        end
      end
    end
  end
end
