namespace :custom do
  desc 'Exec a rake task (-s task="custom:task")'
  task :exec_rake_task do
    on roles(:app) do
      within "#{current_path}" do
        with rails_env: "#{fetch(:stage)}" do
          execute :rake, task
        end
      end
    end
  end
end
