class Admin::EmailReportsController < AdminController
  add_resource_breadcrumbs

  def index
    collection
  end

  protected

    def client
      @_client ||= E9::SendGridClient.new
    end

    def collection
      @email_reports ||= begin
        client.stats(request_arguments)
      rescue => e
        if e.respond_to?(:http_code)
          case e.http_code
          when 400
            flash[:alert] = "Oops, we weren't able to handle the specified date range."
          else
            flash[:alert] = "There was an error processing your request"
          end

          {}
        else
          raise e
        end
      end
    end

    helper_method :collection

    def request_arguments
      {}.tap do |args|
        date = Date.parse(params[:month]) rescue nil
        date ||= Date.today

        start_date = Date.new(date.year, date.month)
        end_date   = [start_date + 1.month - 1.day, Date.today].min

        args[:start_date] = start_date.strftime('%Y-%m-%d')
        args[:end_date]   = end_date.strftime('%Y-%m-%d')

        Rails.logger.error("args: #{args.inspect}")
      end
    end

    class ::EmailReport
      extend ActiveModel::Naming
    end

    def resource_class
      ::EmailReport
    end

end
