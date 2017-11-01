class DocumentDecorator < ::Draper::Decorator

  delegate_all

  def file_preview_link_or_title
    if object.file_links.any?
      h.link_to(object.title,
                h.attachment_url(object.file_links.first, :file),
                class: 'download_link member_link',
                title: 'Click to preview the file',
                target: '_blank').html_safe
    else
      object.title
    end
  end
end

