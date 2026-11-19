
module ApplicationHelper
  def markdown_to_html(text)
    return "".html_safe if text.blank?

    renderer = Redcarpet::Render::HTML.new(
      escape_html: true
    )

    markdown = Redcarpet::Markdown.new(
      renderer,
      autolink: true,
      tables: true,
      fenced_code_blocks: true,
      strikethrough: true
    )

    sanitize(markdown.render(text))
  end
end
