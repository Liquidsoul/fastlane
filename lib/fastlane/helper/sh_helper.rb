module Fastlane
  module Actions
    # Execute a shell command
    # This method will output the string and execute it
    # Just an alias for sh_no_action
    # @param log [boolean] should fastlane print out the executed command
    def self.sh(command, log: true)
      sh_no_action(command, log: log)
    end

    def self.sh_no_action(command, log: true)
      # Set the encoding first, the user might have set it wrong
      previous_encoding = [Encoding.default_external, Encoding.default_internal]
      Encoding.default_external = Encoding::UTF_8
      Encoding.default_internal = Encoding::UTF_8

      command = command.join(' ') if command.kind_of?(Array) # since it's an array of one element when running from the Fastfile
      Helper.log.info ['[SHELL COMMAND]', command.yellow].join(': ') if log

      result = ''
      if false#Helper.test?
        result << command # only for the tests
      else
        begin
          PTY.spawn(command) do |r, w, pid|
            begin
              r.each_line do |line|
                Helper.log.info ['[SHELL]', line.strip].join(': ')
                result << line
              end
            rescue Errno::EIO
            end
          end
          exit_status = $?.to_i
        rescue PTY::ChildExited => e
          exit_status = e.status.to_i
        end

        if exit_status != 0
          raise "Exit status of command '#{command}' was #{exit_status} instead of 0.\n#{result}"
        end
      end

      result
    rescue => ex
      raise ex
    ensure
      Encoding.default_external = previous_encoding.first
      Encoding.default_internal = previous_encoding.last
    end
  end
end
