# frozen_string_literal: true

class Language
  @languages          = []
  @index              = {}
  @name_index         = {}
  @alias_index        = {}
  @language_id_index  = {}

  @extension_index    = Hash.new { |h, k| h[k] = [] }
  @interpreter_index  = Hash.new { |h, k| h[k] = [] }
  @filename_index     = Hash.new { |h, k| h[k] = [] }

  # Detect languages by a specific type
  #
  # type - A symbol that exists within TYPES
  #
  # Returns an array
  def self.by_type(type)
    all.select { |h| h.type == type }
  end

  # Internal: Create a new Language object
  #
  # attributes - A hash of attributes
  #
  # Returns a Language object
  def self.create(attributes = {})
    language = new(attributes)

    @languages << language

    # All Language names should be unique. Raise if there is a duplicate.
    if @name_index.key?(language.name)
      raise ArgumentError, "Duplicate language name: #{language.name}"
    end

    # Language name index
    @index[language.name.downcase] = @name_index[language.name.downcase] = language

    language.aliases.each do |name|
      # All Language aliases should be unique. Raise if there is a duplicate.
      if @alias_index.key?(name)
        raise ArgumentError, "Duplicate alias: #{name}"
      end

      @index[name.downcase] = @alias_index[name.downcase] = language
    end

    language.extensions.each do |extension|
      if extension !~ /^\./
        raise ArgumentError, "Extension is missing a '.': #{extension.inspect}"
      end

      @extension_index[extension.downcase] << language
    end

    language.interpreters.each do |interpreter|
      @interpreter_index[interpreter] << language
    end

    language.filenames.each do |filename|
      @filename_index[filename] << language
    end

    @language_id_index[language.language_id] = language

    language
  end

  # Public: Get all Languages
  #
  # Returns an Array of Languages
  def self.all
    @languages
  end

  def self.find(id)
    find_by_extension(id) ||
      find_by_name(id) ||
      find_by_alias(id) ||
      find_by_filename(id) ||
      find_by_interpreter(id)
  end

  # Public: Look up Language by its proper name.
  #
  # name - The String name of the Language
  #
  # Examples
  #
  #   Language.find_by_name('Ruby')
  #   # => #<Language name="Ruby">
  #
  # Returns the Language or nil if none was found.
  def self.find_by_name(name)
    return nil if !name.is_a?(String) || name.to_s.empty?
    name && (@name_index[name.downcase] || @name_index[name.split(',', 2).first.downcase])
  end

  # Public: Look up Language by one of its aliases.
  #
  # name - A String alias of the Language
  #
  # Examples
  #
  #   Language.find_by_alias('cpp')
  #   # => #<Language name="C++">
  #
  # Returns the Language or nil if none was found.
  def self.find_by_alias(name)
    return nil if !name.is_a?(String) || name.to_s.empty?
    name && (@alias_index[name.downcase] || @alias_index[name.split(',', 2).first.downcase])
  end

  # Public: Look up Languages by filename.
  #
  # The behaviour of this method recently changed.
  # See the second example below.
  #
  # filename - The path String.
  #
  # Examples
  #
  #   Language.find_by_filename('Cakefile')
  #   # => [#<Language name="CoffeeScript">]
  #   Language.find_by_filename('foo.rb')
  #   # => []
  #
  # Returns all matching Languages or [] if none were found.
  def self.find_by_filename(filename)
    basename = File.basename(filename)
    @filename_index[basename]
  end

  # Public: Look up Languages by file extension.
  #
  # The behaviour of this method recently changed.
  # See the second example below.
  #
  # filename - The path String.
  #
  # Examples
  #   Language.find_by_extension('rb')
  # => [#<Language name="Ruby">]
  #
  # Returns all matching Languages or [] if none were found.
  def self.find_by_extension(extension)
    # find the first extension with language definitions
    @extension_index[".#{extension}"]
  end

  # Public: Look up Languages by interpreter.
  #
  # interpreter - String of interpreter name
  #
  # Examples
  #
  #   Language.find_by_interpreter("bash")
  #   # => [#<Language name="Bash">]
  #
  # Returns the matching Language
  def self.find_by_interpreter(interpreter)
    @interpreter_index[interpreter]
  end

  # Public: Look up Languages by its language_id.
  #
  # language_id - Integer of language_id
  #
  # Examples
  #
  #   Language.find_by_id(100)
  #   # => [#<Language name="Elixir">]
  #
  # Returns the matching Language
  def self.find_by_id(language_id)
    @language_id_index[language_id.to_i]
  end

  # Public: Look up Language by its name.
  #
  # name - The String name of the Language
  #
  # Examples
  #
  #   Language['Ruby']
  #   # => #<Language name="Ruby">
  #
  #   Language['ruby']
  #   # => #<Language name="Ruby">
  #
  # Returns the Language or nil if none was found.
  def self.[](name)
    return nil if !name.is_a?(String) || name.to_s.empty?

    lang = @index[name.downcase]
    return lang if lang

    @index[name.split(',', 2).first.downcase]
  end

  # Public: A List of popular languages
  #
  # Popular languages are sorted to the top of language chooser
  # dropdowns.
  #
  # This list is configured in "popular.yml".
  #
  # Returns an Array of Languages.
  def self.popular
    @popular ||= all.select(&:popular?).sort_by { |lang| lang.name.downcase }
  end

  # Public: A List of non-popular languages
  #
  # Unpopular languages appear below popular ones in language
  # chooser dropdowns.
  #
  # This list is created from all the languages not listed in "popular.yml".
  #
  # Returns an Array of Languages.
  def self.unpopular
    @unpopular ||= all.select(&:unpopular?).sort_by { |lang| lang.name.downcase }
  end

  # Public: A List of languages with assigned colors.
  #
  # Returns an Array of Languages.
  def self.colors
    @colors ||= all.select(&:color).sort_by { |lang| lang.name.downcase }
  end

  # Internal: Initialize a new Language
  #
  # attributes - A hash of attributes
  def initialize(attributes = {})
    # @name is required
    @name = attributes[:name] || raise(ArgumentError, 'missing name')

    @fs_name = attributes[:fs_name]

    # Set type
    @type = attributes[:type] ? attributes[:type].to_sym : nil
    if @type && !get_types.include?(@type)
      raise ArgumentError, "invalid type: #{@type}"
    end

    @color = attributes[:color]

    # Set aliases
    @aliases = [default_alias] + (attributes[:aliases] || [])

    @tm_scope = attributes[:tm_scope] || 'none'
    @ace_mode = attributes[:ace_mode]
    @codemirror_mode = attributes[:codemirror_mode]
    @codemirror_mime_type = attributes[:codemirror_mime_type]
    @wrap = attributes[:wrap] || false

    # Set the language_id
    @language_id = attributes[:language_id]

    # Set extensions or default to [].
    @extensions   = attributes[:extensions]   || []
    @interpreters = attributes[:interpreters] || []
    @filenames    = attributes[:filenames]    || []

    # Set popular flag
    @popular    = attributes.key?(:popular) ? attributes[:popular] : false

    # If group name is set, save the name so we can lazy load it later
    if attributes[:group_name]
      @group = nil
      @group_name = attributes[:group_name]

    # Otherwise we can set it to self now
    else
      @group = self
    end
  end

  def get_types
    # Valid Languages types
    @types = [:data, :markup, :programming, :prose]
  end

  # Public: Get proper name
  #
  # Examples
  #
  #   # => "Ruby"
  #   # => "Python"
  #   # => "Perl"
  #
  # Returns the name String
  attr_reader :name

  # Public:
  #
  attr_reader :fs_name

  # Public: Get type.
  #
  # Returns a type Symbol or nil.
  attr_reader :type

  # Public: Get color.
  #
  # Returns a hex color String.
  attr_reader :color

  # Public: Get aliases
  #
  # Examples
  #
  #   Language['C++'].aliases
  #   # => ["cpp"]
  #
  # Returns an Array of String names
  attr_reader :aliases

  # Public: Get language_id (used in GitHub search)
  #
  # Examples
  #
  #   # => "1"
  #   # => "2"
  #   # => "3"
  #
  # Returns the integer language_id
  attr_reader :language_id

  # Public: Get the name of a TextMate-compatible scope
  #
  # Returns the scope
  attr_reader :tm_scope

  # Public: Get Ace mode
  #
  # Examples
  #
  #  # => "text"
  #  # => "javascript"
  #  # => "c_cpp"
  #
  # Returns a String name or nil
  attr_reader :ace_mode

  # Public: Get CodeMirror mode
  #
  # Maps to a directory in the `mode/` source code.
  #   https://github.com/codemirror/CodeMirror/tree/master/mode
  #
  # Examples
  #
  #  # => "nil"
  #  # => "javascript"
  #  # => "clike"
  #
  # Returns a String name or nil
  attr_reader :codemirror_mode

  # Public: Get CodeMirror MIME type mode
  #
  # Examples
  #
  #  # => "nil"
  #  # => "text/x-javascript"
  #  # => "text/x-csrc"
  #
  # Returns a String name or nil
  attr_reader :codemirror_mime_type

  # Public: Should language lines be wrapped
  #
  # Returns true or false
  attr_reader :wrap

  # Public: Get extensions
  #
  # Examples
  #
  #   # => ['.rb', '.rake', ...]
  #
  # Returns the extensions Array
  attr_reader :extensions

  # Public: Get interpreters
  #
  # Examples
  #
  #   # => ['awk', 'gawk', 'mawk' ...]
  #
  # Returns the interpreters Array
  attr_reader :interpreters

  # Public: Get filenames
  #
  # Examples
  #
  #   # => ['Rakefile', ...]
  #
  # Returns the extensions Array
  attr_reader :filenames

  # Public: Get URL escaped name.
  #
  # Examples
  #
  #   "C%23"
  #   "C%2B%2B"
  #   "Common%20Lisp"
  #
  # Returns the escaped String.
  def escaped_name
    EscapeUtils.escape_url(name).gsub('+', '%20')
  end

  # Public: Get default alias name
  #
  # Returns the alias name String
  def default_alias
    name.downcase.gsub(/\s/, '-')
  end
  alias_method :default_alias_name, :default_alias

  # Public: Get Language group
  #
  # Returns a Language
  def group
    @group ||= Language.find_by_name(@group_name)
  end

  # Public: Is it popular?
  #
  # Returns true or false
  def popular?
    @popular
  end

  # Public: Is it not popular?
  #
  # Returns true or false
  def unpopular?
    !popular?
  end

  # Public: Return name as String representation
  def to_s
    name
  end

  def ==(other)
    eql?(other)
  end

  def eql?(other)
    equal?(other)
  end

  def hash
    name.hash
  end

  def inspect
    "#<#{self.class} name=#{name}>"
  end

  languages = YAML.load_file(Rails.root.join('config/languages.yml'))
  popular = YAML.load_file(Rails.root.join('config/popular_languages.yml'))

  languages.each do |name, options|
    options['extensions']   ||= []
    options['interpreters'] ||= []
    options['filenames']    ||= []

    Language.create(
      name: name,
      fs_name: options['fs_name'],
      color: options['color'],
      type: options['type'],
      aliases: options['aliases'],
      tm_scope: options['tm_scope'],
      ace_mode: options['ace_mode'],
      codemirror_mode: options['codemirror_mode'],
      codemirror_mime_type: options['codemirror_mime_type'],
      wrap: options['wrap'],
      group_name: options['group'],
      language_id: options['language_id'],
      extensions: Array(options['extensions']),
      interpreters: options['interpreters'].sort,
      filenames: options['filenames'],
      popular: popular.include?(name)
    )
  end
end
