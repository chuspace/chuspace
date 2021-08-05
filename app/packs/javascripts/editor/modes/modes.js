export type ModeType = {
  name: string,
  mode: string,
  mime?: string,
  custom?: boolean
}

export type ModesType = Array<LanguageType>

export const MODES: ModesType = [
  {
    name: 'Auto',
    mode: 'auto'
  },
  {
    name: 'Apache',
    mode: 'apache',
    mime: 'text/apache',
    custom: true
  },
  {
    name: 'Bash',
    mode: 'shell',
    mime: 'application/x-sh'
  },
  {
    name: 'Plain Text',
    mode: 'text'
  },
  {
    name: 'C',
    mode: 'clike',
    mime: 'text/x-csrc',
    short: 'c'
  },
  {
    name: 'C++',
    mode: 'clike',
    mime: 'text/x-c++src',
    short: 'cpp'
  },
  {
    name: 'C#',
    mode: 'clike',
    mime: 'text/x-csharp',
    short: 'cs'
  },
  {
    name: 'Clojure',
    mode: 'clojure'
  },
  {
    name: 'Cobol',
    mode: 'cobol'
  },
  {
    name: 'CoffeeScript',
    mode: 'coffeescript'
  },
  {
    name: 'Crystal',
    mode: 'crystal'
  },
  {
    name: 'CSS',
    mode: 'css'
  },
  {
    name: 'D',
    mode: 'd'
  },
  {
    name: 'Dart',
    mode: 'dart'
  },
  {
    name: 'Diff',
    mode: 'diff',
    mime: 'text/x-diff'
  },
  {
    name: 'Django',
    mode: 'django'
  },
  {
    name: 'Docker',
    mode: 'dockerfile'
  },
  {
    name: 'Elixir',
    mode: 'elixir',
    custom: true
  },
  {
    name: 'Elm',
    mode: 'elm'
  },
  {
    name: 'Erlang',
    mode: 'erlang'
  },
  {
    name: 'Fortran',
    mode: 'fortran'
  },
  {
    name: 'F#',
    mode: 'mllike'
  },
  {
    name: 'Gherkin',
    mode: 'gherkin'
  },
  {
    name: 'GraphQL',
    mode: 'graphql',
    custom: true
  },
  {
    name: 'Go',
    mode: 'go',
    mime: 'text/x-go'
  },
  {
    name: 'Groovy',
    mode: 'groovy'
  },
  {
    name: 'Handlebars',
    mode: 'handlebars'
  },
  {
    name: 'Haskell',
    mode: 'haskell'
  },
  {
    name: 'Haxe',
    mode: 'haxe'
  },
  {
    name: 'HTML',
    mode: 'htmlmixed'
  },
  {
    name: 'Java',
    mode: 'clike',
    mime: 'text/x-java',
    short: 'java'
  },
  {
    name: 'JavaScript',
    mode: 'javascript',
    short: 'javascript'
  },
  {
    name: 'JSON',
    mode: 'javascript',
    mime: 'application/json',
    short: 'json'
  },
  {
    name: 'JSX',
    mode: 'jsx'
  },
  {
    name: 'Julia',
    mode: 'julia'
  },
  {
    name: 'Kotlin',
    mode: 'clike',
    mime: 'text/x-kotlin',
    short: 'kotlin'
  },
  {
    name: 'LaTeX',
    mode: 'stex'
  },
  {
    name: 'Lisp',
    mode: 'commonlisp'
  },
  {
    name: 'Lua',
    mode: 'lua'
  },
  {
    name: 'Markdown',
    mode: 'markdown'
  },
  {
    name: 'Mathematica',
    mode: 'mathematica'
  },
  {
    name: 'MATLAB/Octave',
    mode: 'octave',
    mime: 'text/x-octave'
  },
  {
    name: 'MySQL',
    mode: 'sql',
    mime: 'text/x-mysql',
    short: 'mysql'
  },
  {
    name: 'N-Triples',
    mode: 'ntriples',
    mime: 'application/n-triples'
  },
  {
    name: 'NGINX',
    mode: 'nginx'
  },
  {
    name: 'Objective C',
    mode: 'clike',
    mime: 'text/x-objectivec',
    short: 'objectivec'
  },
  {
    name: 'OCaml',
    mode: 'mllike'
  },
  {
    name: 'Pascal',
    mode: 'pascal'
  },
  {
    name: 'Perl',
    mode: 'perl'
  },
  {
    name: 'PHP',
    mode: 'php',
    mime: 'text/x-php',
    short: 'php'
  },
  {
    name: 'PowerShell',
    mode: 'powershell'
  },
  {
    name: 'Python',
    mode: 'python'
  },
  {
    name: 'R',
    mode: 'r'
  },
  {
    name: 'Ruby',
    mode: 'ruby'
  },
  {
    name: 'Rust',
    mode: 'rust'
  },
  {
    name: 'Sass',
    mode: 'sass'
  },
  {
    name: 'Scala',
    mode: 'clike',
    mime: 'text/x-scala',
    short: 'scala'
  },
  {
    name: 'Smalltalk',
    mode: 'smalltalk'
  },
  {
    name: 'SPARQL',
    mode: 'sparql',
    mime: 'application/sparql-query'
  },
  {
    name: 'SQL',
    mode: 'sql'
  },
  {
    name: 'Stylus',
    mode: 'stylus',
    mime: 'stylus'
  },
  {
    name: 'Swift',
    mode: 'swift'
  },
  {
    name: 'TCL',
    mode: 'tcl'
  },
  {
    name: 'TOML',
    mode: 'toml'
  },
  {
    name: 'Turtle',
    mode: 'turtle',
    mime: 'text/turtle'
  },
  {
    name: 'TypeScript',
    mode: 'javascript',
    mime: 'application/typescript',
    short: 'typescript'
  },
  {
    name: 'TSX',
    mode: 'jsx',
    mime: 'text/typescript-jsx',
    short: 'tsx'
  },
  {
    name: 'Twig',
    mode: 'twig',
    mime: 'text/x-twig'
  },
  {
    name: 'VB.NET',
    mode: 'vb'
  },
  {
    name: 'Verilog',
    mode: 'verilog'
  },
  {
    name: 'VHDL',
    mode: 'vhdl'
  },
  {
    name: 'Vue',
    mode: 'vue'
  },
  {
    name: 'XML',
    mode: 'xml'
  },
  {
    name: 'YAML',
    mode: 'yaml'
  }
]
