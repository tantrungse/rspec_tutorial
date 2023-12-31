require "rails_helper"

describe ContactsController do

    shared_examples "public access to contacts" do
        
        describe "GET #index" do
            context "with params[:letter]" do
                it "populates an array of contacts starting with the letter" do
                    smith = create(:contact, lastname: "Smith")
                    jones = create(:contact, lastname: "Jones")
                    get :index, params: { letter: "S" }
                    expect(assigns(:contacts)).to match_array([smith])
                end

                it "renders the :index template" do
                    get :index, params: { letter: "S" }
                    expect(response).to render_template :index
                end
            end

            context "without params[:letter]" do
                it "populates an array of all contacts" do
                    smith = create(:contact, lastname: "Smith")
                    jones = create(:contact, lastname: "Jones")
                    get :index
                    expect(assigns(:contacts)).to match_array([smith, jones])
                end

                it "renders the :index template" do
                    get :index
                    expect(response).to render_template :index
                end
            end
        end

        describe "GET #show" do
            it "assigns the requested contact to @contact" do
                contact = create(:contact)
                get :show, params: { id: contact.id }
                expect(assigns(:contact)).to eq contact
            end
            
            it "renders the :show template" do
                contact = create(:contact)
                get :show, params: { id: contact.id }
                expect(response).to render_template :show
            end
        end
    end

    shared_examples "full access to contacts" do

        describe "GET #new" do
            it "assigns a new contact to @contact" do
                get :new
                expect(assigns(:contact)).to be_a_new(Contact)
            end

            it "renders the :new template" do
                get :new
                expect(response).to render_template :new
            end
        end

        describe "GET #edit" do
            it "assigns the requested contact to @contact" do
                contact = create(:contact)
                get :edit, params: { id: contact.id }
                expect(assigns(:contact)).to eq contact
            end

            it "renders the :edit template" do
                contact = create(:contact)
                get :edit, params: { id: contact.id }
                expect(response).to render_template :edit
            end
        end

        describe "POST #create" do
            before :each do
                @phones = [
                    attributes_for(:phone),
                    attributes_for(:phone),
                    attributes_for(:phone)
                ]
            end

            context "with valid attributes" do
                it "saves the new contact in the database" do
                    expect {
                        post :create, params: {
                            contact: attributes_for(:contact, phones_attributes: @phones)
                        }
                    }.to change(Contact, :count).by(1)
                end

                it "redirects to contacts#show" do
                    post :create, params: {
                        contact: attributes_for(:contact, phones_attributes: @phones)
                    }
                    expect(response).to redirect_to contact_path(assigns[:contact])
                end
            end

            context "with invalid attributes" do
                it "does not save the new contact in the database" do
                    expect {
                        post :create, params: {
                            contact: attributes_for(:invalid_contact)
                        }
                    }.to_not change(Contact, :count)
                end

                it "re-renders the :new template" do
                    post :create, params: {
                        contact: attributes_for(:invalid_contact)
                    }
                    expect(response).to render_template :new
                end
            end
        end

        describe "PATCH #update" do
            before :each do
                @contact = create(
                    :contact,
                    firstname: "Lawrence",
                    lastname: "Smith"
                )
            end

            context "with valid attributes" do
                it "locates the requested @contact" do
                    patch :update, params: {
                        id: @contact, 
                        contact: attributes_for(:contact)
                    }
                    expect(assigns(:contact)).to eq(@contact)
                end

                it "changes @contact's attributes" do
                    patch :update, params: {
                        id: @contact,
                        contact: attributes_for(
                            :contact,
                            firstname: "Larry",
                            lastname: "Smith"
                        )
                    }
                    @contact.reload
                    expect(@contact.firstname).to eq("Larry")
                    expect(@contact.lastname).to eq("Smith")
                end

                it "redirects to the updated contact" do
                    patch :update, params: {
                        id: @contact,
                        contact: attributes_for(:contact)
                    }
                    expect(response).to redirect_to @contact
                end
            end

            context "with invalid attributes" do
                it "does not change the contact's attributes" do
                    patch :update, params: {
                        id: @contact,
                        contact: attributes_for(
                            :contact,
                            firstname: "Larry",
                            lastname: nil
                        )
                    }
                    @contact.reload
                    expect(@contact.firstname).to_not eq("Larry")
                    expect(@contact.lastname).to eq("Smith")
                end

                it "re-renders the #edit template" do
                    patch :update, params: {
                        id: @contact,
                        contact: attributes_for(:invalid_contact)
                    }
                    expect(response).to render_template :edit
                end
            end
        end

        describe "DELETE #destroy" do
            before :each do
                @contact = create(:contact)
            end

            it "deletes the contact" do
                expect {
                    delete :destroy,
                    params: { id: @contact }
                }.to change(Contact, :count).by(-1)
            end

            it "redirects to contacts#index" do
                delete :destroy, params: { id: @contact }
                expect(response).to redirect_to contacts_url
            end
        end
    end

    describe "administrator access" do

        before :each do
            set_user_session create(:admin)
        end

        it_behaves_like "public access to contacts"
        it_behaves_like "full access to contacts"

    end

    describe "user access" do

        before :each do
            set_user_session create(:user)
        end

        it_behaves_like "public access to contacts"
        it_behaves_like "full access to contacts"
    end

    describe "guest access" do

        it_behaves_like "public access to contacts"

        describe "GET #new" do
            it "requires login" do
                get :new
                expect(response).to require_login
            end
        end

        describe "GET #edit" do
            it "requires login" do
                contact = create(:contact)
                get :edit, params: { id: contact }
                expect(response).to require_login
            end
        end

        describe "POST #create" do
            it "requires login" do
                post :create, params: {
                    id: create(:contact),
                    contact: attributes_for(:contact)
                }
                expect(response).to require_login
            end
        end

        describe "PATCH #update" do
            it "requires login" do
                put :update, params: {
                    id: create(:contact),
                    contact: attributes_for(:contact)
                }
                expect(response).to require_login
            end
        end

        describe "DELETE #destroy" do
            it "requires login" do
                delete :destroy, params: { id: create(:contact) }
                expect(response).to require_login
            end
        end
    end
end