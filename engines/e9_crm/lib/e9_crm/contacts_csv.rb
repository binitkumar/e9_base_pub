require 'csv'

module E9Crm
  module ContactsCsv
    extend ActiveSupport::Concern

    CSV_MAPPINGS = ActiveSupport::OrderedHash.new
    CSV_MAPPINGS[:first_name]  = 'First Name'
    CSV_MAPPINGS[:last_name]   = 'Last Name'
    CSV_MAPPINGS[:email]       = 'Email'
    CSV_MAPPINGS[:phone]       = 'Phone'
    CSV_MAPPINGS[:address]     = 'Address'
    CSV_MAPPINGS[:info]        = 'Notes'
    CSV_MAPPINGS[:tags]        = 'Tags'
    CSV_MAPPINGS[:subscribed]  = 'Newsletter?'
    CSV_MAPPINGS[:ok_to_email] = 'CRM Mail OK?'
    CSV_MAPPINGS[:company]     = 'Company'
    CSV_MAPPINGS[:title]       = 'Title'
    CSV_MAPPINGS.freeze

    Row = Struct.new(*CSV_MAPPINGS.keys)

    included do
      filter_access_to :upload_csv, :context => :admin, :require => :update
      respond_to :csv, :only => :index
    end

    def index
      index! do |format|
        format.csv { render_csv }
        format.html
        format.json
        format.js
      end
    end

    def upload_csv
      respond_to do |format|
        format.js { render :json => parse_csv }
      end
    end

    protected

      def parse_csv
        errors, json = {}, {}

        csv = params[:csv]

        if csv.respond_to?(:original_filename) && csv.original_filename =~ /\.csv$/i
          json[:info] = { :created => 0, :updated => 0 }

          lineno = 0

          CSV.foreach(csv.tempfile, :headers => true) do |row|
            key = nil
            r = Row.new(*row.map(&:last))

            Rails.logger.error(r.inspect)
            lineno += 1

            contact = nil

            if r.email.present?
              # find of create the user with the given email
              user = User.find_by_email(r.email) || begin
                key = :created
                User.prospects.create({
                  :email         => r.email,
                  :first_name    => r.first_name,
                  :last_name     => r.last_name
                })
              end

              # if the user creation failed, add the errors and skip
              # to contact updating without a user
              if ! user.persisted?
                errors[:user] ||= []
                errors[:user] << {:row => lineno, :errors => user.errors.full_messages}
                next
              else
                # if user is a prospect and the names don't match, update
                # them (this won't occur if the user was just created, as
                # the names are already correct)
                if user.prospect? and
                   user.first_name != r.first_name ||
                   user.last_name  != r.last_name

                  user.update_attributes({
                    :first_name => r.first_name,
                    :last_name => r.last_name
                  })
                end

                if r.subscribed == '1'
                  user.mailing_lists = user.mailing_lists | [_default_mailing_list]
                else
                  user.mailing_lists = user.mailing_lists - [_default_mailing_list]
                end

                unless user.contact.present?
                  key = :created
                  user.create_contact_if_missing!
                  user.reload
                end

                contact = user.contact
              end
            end

            contact ||= Contact.new

            key ||= contact.new_record? ? :created : :updated

            # basic columns
            contact.first_name   = r.first_name.presence || contact.first_name
            contact.last_name    = r.last_name.presence  || contact.last_name
            contact.info         = r.info.presence       || contact.info
            contact.company_name = r.company.presence    || contact.company_name
            contact.title        = r.title.presence      || contact.title

            contact.ok_to_email = case r.ok_to_email
              when '1' then true
              when '0' then false
              else contact.ok_to_email
            end

            if phone = r.phone.presence
              phone = _squeeze_and_strip(phone)

              existing = _contact_work_phone(contact)

              attr = if existing.blank?
                { :value => phone, :options => { :type => 'Work' }}
              elsif _squeeze_and_strip(existing.value) != phone
                existing.value = phone
                existing.attributes.symbolize_keys.slice(:id, :options, :value)
              end

              contact.phone_number_attributes_attributes = [attr] if attr
            end

            if address = r.address.presence
              address = _squeeze_and_strip(address)

              existing = _contact_work_address(contact)

              attr = if existing.blank?
                { :value => address, :options => { :type => 'Work' }}
              elsif _squeeze_and_strip(existing.value) != address
                existing.value = address
                existing.attributes.symbolize_keys.slice(:id, :options, :value)
              end

              contact.address_attributes_attributes = [attr] if attr
            end

            # tags
            if r.tags.present?
              existing_tags = contact.tag_list_on('users__h__')
              tags          = r.tags.split('|').map(&:strip)
              combined_tags = tags | existing_tags

              contact.tag_lists = {'users__h__' => combined_tags }
            end

            if contact.save
              json[:info][key] += 1
            else
              errors[:contact] ||= []
              errors[:contact] << {:row => lineno, :errors => contact.errors.full_messages }
            end
          end
        elsif csv.present?
          errors[:incorrect_filetype] = true
        else
          errors[:missing_file] = true
        end

        json[:errors] = errors unless errors.empty? 
        json
      end

      def generate_csv
        CSV.generate do |csv| 
          csv << CSV_MAPPINGS.values

          end_of_association_chain.all.each do |contact|
            csv << [
              contact.first_name,
              contact.last_name,
              contact.email,
              _squeeze_and_strip(_contact_work_phone(contact).try(:value)),
              _squeeze_and_strip(_contact_work_address(contact).try(:value)),
              contact.info,
              contact.tag_list_on('users__h__').join('|'),
              _user_subscribed_value(contact.primary_user),
              contact.ok_to_email ? '1' : '0',
              contact.company_name,
              contact.title
            ]
          end
        end
      end

      def render_csv
        filename = 'contacts.csv'

        if request.env['HTTP_USER_AGENT'] =~ /msie/i
          headers['Pragma'] = 'public'
          headers["Content-type"] = "text/plain" 
          headers['Cache-Control'] = 'no-cache, must-revalidate, post-check=0, pre-check=0'
          headers['Content-Disposition'] = "attachment; filename=\"#{filename}\"" 
          headers['Expires'] = "0" 
        else
          headers["Content-Type"] ||= 'text/csv'
          headers["Content-Disposition"] = "attachment; filename=\"#{filename}\"" 
        end

        send_data(generate_csv)
      end

    private

      def _user_subscribed_value(user)
        user && user.mailing_lists.member?(_default_mailing_list) ? '1' : '0'
      end

      def _default_mailing_list
        @_default_mailing_list ||= MailingList.default
      end

      def _contact_work_phone(contact)j
        contact.phone_number_attributes.attr_like(:options, "Work").first
      end

      def _contact_work_address(contact)
        contact.address_attributes.attr_like(:options, "Work").first
      end

      def _squeeze_and_strip(str)
        str && str.squeeze(' ').strip
      end

  end
end
