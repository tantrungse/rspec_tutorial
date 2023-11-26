FactoryBot.define do
    factory :contact do
        firstname { FFaker::Name.first_name }
        lastname { FFaker::Name.last_name }
        email { FFaker::Internet.email }

        after(:build) do |contact|
            [:home_phone, :work_phone, :mobile_phone].each do |phone|
                contact.phones << FactoryBot.build(
                    :phone,
                    phone_type: phone,
                    contact: contact
                )
            end
        end

        factory :invalid_contact do
            firstname { nil }
        end
    end
end