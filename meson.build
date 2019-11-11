project('TDC', 'd', version: '0.0.1 FarBelow', license: 'BSL-1.0')

conf = configuration_data()
conf.set('NAME',    meson.project_name())
conf.set('VERSION', meson.project_version())
conf.set('LICENSE', meson.project_license()[0])

configure_file(
    input:  'source/compiler.d.in',
    output: 'compiler.d',
    configuration: conf
)

source = files(
    meson.current_build_dir() + '/compiler.d',

    'source/backend/amd64.d',
    'source/backend/package.d',
    'source/frontend/lexer.d',
    'source/frontend/package.d',
    'source/frontend/parser.d',
    'source/language/ast.d',
    'source/language/token.d',
    'source/utils/files.d',
    'source/utils/messages.d',
    'source/main.d'
)

e = executable(
    meson.project_name().to_lower(),
    source,
    include_directories: include_directories('source'),
    install: true
)

as = find_program('cc')

test('Basics',      e,  args: ['-c', files('test/basics.d'), '-o', 'basics.S'])
test('Basics + as', as, args: ['-c', 'basics.S', '-o', 'basics.o'], is_parallel: false)
