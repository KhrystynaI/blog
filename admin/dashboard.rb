ActiveAdmin.register_page 'Dashboard' do
  menu priority: 1, label: proc { I18n.t('active_admin.dashboard') }

  content title: proc { I18n.t('active_admin.dashboard') } do
    columns do
      column do
        panel 'Common Actions' do
          span do
            link_to 'New Document', new_admin_document_path, class: 'button'
          end
          span do
            link_to 'New Document Set', new_admin_document_set_path, class: 'button'
          end
        end
      end

      column do
        panel 'General Stats' do
          div do
            ul do
              li do
                "#{Customer.count} Customers"
              end
              li do
                "#{Vendor.count} Vendors"
              end
              li do
                "#{Document.count} Documents #{Document.active.count}"
              end
              li do
                "#{DocumentSet.count} Document Sets "\
                "(#{DocumentSet._new.count} New/#{DocumentSet.in_progress.count} In progress/#{DocumentSet.published.count} Published)/#{DocumentSet.archived.count} Archived)"
              end
            end
          end
        end
      end
    end
  end
end
