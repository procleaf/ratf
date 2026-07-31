class LogParser
  def self.parse_file(file_path)
    entries = []
    File.open(file_path, 'r') do |file|
      file.each_line do |line|
        parsed = parse_line(line)
        entries << parsed if parsed
      end
    end
    entries
  end
  
  def self.parse_text(text)
    text.lines.map { |line| parse_line(line) }.compact
  end

  def self.parse_line(line)
    # Example log line format: [2024-01-15 10:30:45] [INFO] Message here
    match = line.match(/\[(.*?)\]\s+\[(.*?)\]\s+(.*)/)
    return nil unless match
    
    {
      timestamp: Time.parse(match[1]),
      level: match[2].downcase.to_sym,
      message: match[3].strip
    }
  rescue
    # Fallback for non-standard logs
    { message: line.strip, timestamp: Time.now, level: :debug }
  end
end
