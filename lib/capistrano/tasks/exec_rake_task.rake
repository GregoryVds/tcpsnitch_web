set :task, ENV['task'] || raise('missing task="task_name"')

namespace :custom do
  desc 'Exec a rake task (task="custom:task")'
  task :exec_rake_task do |task_name, param|
    on roles(:app) do
      within "#{current_path}" do
        with rails_env: "#{fetch(:stage)}" do
          execute :rake, fetch(:task)
        end
      end
    end
  end
end
