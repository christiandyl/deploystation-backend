module Formatters
  class LoggerFormatter
    USE_HUMOROUS_SEVERITIES = true

    def call(severity, time, progname, message)
      direct_prg_line = stack_line = buffer = buffer2 = ""

      message.split("\n").each do |line|
        next if line == ""
        line.gsub!(/^Started ([A-Z]+) /, "\033[0;1;34m\\0\033[0m")
        line = "%s - %s - #%d - %s%s%s\n" % [
          Time.now.strftime("%Y-%m-%d %H:%M:%S.%L"),
          severity,
          $$,
          direct_prg_line,
          line,
          stack_line
        ]

        buffer += line
      end

      return buffer
    end
  end
end