class IO
  def get_password(out: $stderr)
    result = ''
    noecho do
      while char = getch
        case char
        when /[\r\n]/
          break
        when /[\e\b\x7f]/
          result.replace result.chop
          out.write "\b \b"
        when /[\x3\x1A]/ # interrupt, background
          out.write "\nOk, aborting\n"
          abort
        else
          result << char
          out.write '*'
        end
      end
    end
    out.write "\n"
    result
  end
end
