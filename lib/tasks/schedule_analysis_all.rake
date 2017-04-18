namespace :custom do
  desc 'Schedule analysis all'
  task :schedule_analysis_all => :environment do
    Dataset.get.schedule_analysis
    AppTrace.all.each(&:schedule_analysis)
    ProcessTrace.all.each(&:schedule_analysis)
    SocketTrace.all.each(&:schedule_analysis)
  end
end
