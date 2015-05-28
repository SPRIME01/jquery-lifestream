module Canvas
  class TurnitinReporter < Csv
    include ClassLogger

    def self.print_current_term
      current_term_id = Canvas::Proxy.current_sis_term_ids.first
      worker = TurnitinReporter.new(current_term_id)
      csv_filename = worker.generate_csv
      parsed_csv = CSV.read(csv_filename, {headers: true})
      print parsed_csv.to_csv
    end

    def initialize(sis_term_id)
      super()
      @sis_term_id = sis_term_id
    end

    def generate_report
      enabled_courses = 0
      enabled_assignments = 0
      report_rows = []

      # Download Canvas Courses in the TurnItIn-enabled sub-account for the current term.
      canvas_courses = Canvas::CoursesReport.new(account_id: Settings.canvas_proxy.turnitin_account_id).get_csv(@sis_term_id);

      # Loop through the Course Sites which are in the special TurnItIn-enabled sub-account.
      canvas_courses.each do |course_row|
        course_enabled = false
        assignments = Canvas::CourseAssignments.new(course_id: course_row['canvas_course_id']).course_assignments
        assignments.each do |assignment|
          if assignment['turnitin_enabled']
            course_enabled = true
            enabled_assignments += 1
            report_rows << {
              'Course ID' => assignment['course_id'],
              'Course Code' => course_row['short_name'],
              'Assignment URL' => assignment['html_url'],
              'Assignment Name' => assignment['name'],
              'Creation Date' => assignment['created_at']
            }
          end
        end
        enabled_courses += 1 if course_enabled
      end

      report_rows << {
        'Total Enabled Courses' => enabled_courses,
        'Total Enabled Assignments' => enabled_assignments
      }
      report_rows
    end

    def generate_csv
      data_rows = generate_report
      header_row = data_rows.first.keys if data_rows.length > 1
      header_row.concat data_rows.last.keys
      csv_filename = "#{@export_dir}/turnitin-#{file_safe(@sis_term_id)}-#{DateTime.now.strftime('%F')}.csv"
      make_csv(csv_filename, header_row, data_rows)
    end

  end
end
