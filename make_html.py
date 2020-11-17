# -*- coding: utf-8 -*-

import markdown2 as md2
from string import Template
from pathlib import Path

MD_EXTRAS = ['code-friendly',
             'fenced-code-blocks',
             'footnotes',
             'header-ids',
             'markdown-in-html',
             'metadata',
             'smarty-pants',
             'toc',
             'xml']

def changed_files(template_file, input_folder, output_folder):
    template_mtime = template_file.stat().st_mtime
    # This is why paths must be relative
    # Input/nana/file -> nana/file
    # Output/nana/file -> nana/file
    input_mtimes = {f.with_suffix('').parts[1:]: f.stat().st_mtime
                        for f in input_folder.iterdir()}
    output_mtimes = {f.with_suffix('').parts[1:]: f.stat().st_mtime
                        for f in output_folder.iterdir()}
    for f, in_time in input_mtimes.items():
        out_time = output_mtimes.get(f, -1)
        if out_time < in_time or out_time < template_mtime:
            yield Path(*f).with_suffix('.md')

def params(args):
    # These must be relative paths (see changed_files())
    template_file = 'Template.html'
    input_folder = 'Input/'
    output_folder = 'Output/'
    if '--template' in args:
        i = args.index('--template') + 1
        template_file = args[i] if Path(args[i]).is_file() else template_file
    if '--input' in args:
        i = args.index('--input') + 1
        input_folder = args[i] if Path(args[i]).is_dir() else input_folder
    if '--output' in args:
        i = args.index('--output') + 1
        output_folder = args[i] if Path(args[i]).is_dir() else output_folder
    template_file = Path(template_file)
    input_folder = Path(input_folder)
    output_folder = Path(output_folder)
    return template_file, input_folder, output_folder

def main():
    import sys
    args = sys.argv[1:]
    template_file, input_folder, output_folder = params(args)
    to_update = changed_files(template_file, input_folder, output_folder)
    template = Template(template_file.read_text())
    markdowner = md2.Markdown(extras=MD_EXTRAS)
    for f in to_update:
        print(input_folder / f)
        input_md = (input_folder / f).read_text(encoding='utf-8')
        converted = md2.markdown(input_md, extras=MD_EXTRAS)
        meta = converted.metadata if converted.metadata else {}
        toc = converted.toc_html if converted.toc_html else ''
        # Applying the template twice.
        # Why? I want variables in the Markdown too.
        output_html = template.safe_substitute(content=converted)
        output_html = Template(output_html).safe_substitute(converted.metadata,
                                                            toc=toc)
        (output_folder / f).with_suffix('.html').write_text(output_html,
                                                            encoding='utf-8')

if __name__ == '__main__':
    main()
