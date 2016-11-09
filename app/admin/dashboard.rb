ActiveAdmin.register_page 'Dashboard' do

  menu priority: 1, label: proc{ I18n.t("active_admin.dashboard") }

  content title: proc{ I18n.t("active_admin.dashboard") } do
    columns do
      column do
        panel "Total users" do
          div { User.count }
        end
      end
      column do
        panel "Total servers" do
          div { Container.count }
        end
      end
      column do
        panel "Total payments amount" do
          div { Payment.sum(:amount) }
        end
      end
      column do
        panel "Total payments amount for today" do
          div { Payment.where("created_at >= ?", Time.zone.now.beginning_of_day).sum(:amount) }
        end
      end
    end

    columns do
      column do
        panel "Recent users during last 24 hours" do
          table_for User.order('id desc').limit(30).where(created_at: 24.hours.ago..Time.now).each do |user|
            column(:email) { |user| link_to(user.email, admin_user_path(user)) }
            column(:full_name) { |user| user.full_name }
            column(:country) { |user| user.country }
            column(:created_at) { |user| user.created_at }
          end
        end
      end
      column do
        panel "Recent payments during last 24 hours" do
          table_for Payment.order('id desc').limit(30).where(created_at: 24.hours.ago..Time.now).each do |payment|
            column(:amount) { |payment| payment.amount }
            column(:provider) { |payment| payment.provider }
            column(:user) { |payment| link_to(payment.user.email, admin_user_path(payment.user)) }
          end
        end
      end
    end

  end
end
