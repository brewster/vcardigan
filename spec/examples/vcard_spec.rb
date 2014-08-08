require File.dirname(__FILE__) + '/../spec_helper'

describe VCardigan::VCard do

  describe '#init' do
    context 'no options' do
      let(:vcard) { VCardigan.create }
      
      it 'should set default version' do
        vcard.version.should == '4.0'
      end

      it 'should set default line char limit' do
        vcard.chars.should == 75
      end
    end

    context 'version number for args (backward compat)' do
      let(:version) { '3.0' }
      let(:vcard) { VCardigan.create(version) }

      it 'should set version' do
        vcard.version.should == version
      end
    end

    context 'passed options args' do
      let(:version) { '3.0' }
      let(:chars) { 100 }
      let(:vcard) { VCardigan.create(:version => version, :chars => chars) }

      it 'should set version' do
        vcard.version.should == version
      end

      it 'should set line char limit' do
        vcard.chars.should == chars
      end
    end
  end

  describe '#[]' do
    let(:group) { :item1 }
    let(:vcard) { VCardigan.create }

    before do
      vcard[group]
    end

    it 'should return vcard' do
      vcard.should be_an_instance_of(VCardigan::VCard)
    end

    it 'should set group' do
      vcard.instance_variable_get(:@group).should == group
    end
  end

  describe '#add' do
    let(:name) { :email }
    let(:value) { 'joe@strummer.com' }
    let(:vcard) { VCardigan.create }
    let(:fields) { vcard.instance_variable_get(:@fields) }

    context 'with no group' do
      before do
        vcard.add(name, value)
      end

      it 'should add field name (as string) to fields hash' do
        fields.should have_key(name.to_s)
      end

      it 'should create array on field name' do
        fields[name.to_s].should be_an_instance_of(Array)
      end

      it 'should have single item in array' do
        fields[name.to_s].length.should == 1
      end

      it 'should add property to field name array' do
        fields[name.to_s].first.should be_an_instance_of(VCardigan::Property)
      end
    end

    context 'with group' do
      let(:group) { :item1 }
      let(:groups) { vcard.instance_variable_get(:@groups) }

      before do
        vcard[group].add(name, value)
      end

      it 'should add group name (as string) to groups hash' do
        groups.should have_key(group.to_s)
      end

      it 'should create array on group name' do
        groups[group.to_s].should be_an_instance_of(Array)
      end

      it 'should have single item in array' do
        groups[group.to_s].length.should == 1
      end

      it 'should add property group name array' do
        groups[group.to_s].first.should be_an_instance_of(VCardigan::Property)
      end
    end
  end

  describe "#remove" do
    let(:vcard) { VCardigan.create }
    let(:name) { :email }
    let(:email) { 'joe@strummer.com' }
    let(:params) { { :type => 'uri' } }
    let(:fields) { vcard.instance_variable_get(:@fields) }

    context "with no group" do
      before do
        vcard.add(name, email, params)
      end

      it "removes all occurances of the field" do
        fields['email'].should_not be_empty

        vcard.remove('email')

        fields['email'].should be_nil
      end
    end

    context "with groups" do
      let(:group) { 'item1' }
      let(:label) { 'Test Label' }
      before do
        vcard['item0'].add('tel', '235235')
        vcard['item0'].add('x-ablabel', 'iPhone')
        vcard[group].add(name, email)
        vcard[group].add('x-ablabel', label)
      end

      it "removes all occurances of the field and its group label" do
        vcard[group].email.first.value.should_not be_empty
        vcard[group].send('x-ablabel').first.value.should == label

        vcard.remove('email')

        fields['email'].should be_nil

        vcard[group].send('x-ablabel').should be_empty
      end
    end
  end

  describe '#method_missing' do
    let(:vcard) { VCardigan.create }

    context 'with args' do
      let(:name) { :email }
      let(:email) { 'joe@strummer.com' }
      let(:params) { { :type => 'uri' } }

      it 'should call #add' do
        vcard.should_receive(:add).with(name, email, params)
        vcard.send(name, email, params)
      end
    end

    context 'without args' do
      let(:name) { :email }

      it 'should call #field' do
        vcard.should_receive(:field).with(name)
        vcard.send(name)
      end
    end
  end

  describe '#field' do
    let(:vcard) { VCardigan.create }
    let(:fields) { vcard.instance_variable_get(:@fields) }
    let(:name) { :email }
    let(:value) { 'joe@strummer.com' }

    context 'no group' do
      before do
        vcard.send(name, value)
      end

      it 'should return field name array' do
        vcard.field(name).should == fields[name.to_s]
      end

      it 'should have correct property in array' do
        vcard.field(name).first.value.should == value
      end
    end

    context 'with group' do
      let(:group) { :item1 }
      let(:value2) { 'joestrummer@strummer.com' }

      before do
        vcard.send(name, value)
        vcard[group].send(name, value2)
      end

      it 'should return field name array with props within group' do
        vcard[group].field(name).should == fields[name.to_s].find_all do |prop|
          prop.group == group.to_s
        end
      end

      it 'should have correct property in array' do
        vcard[group].field(name).first.value.should == value2
      end
    end
  end

  describe 'Aliases' do
    let(:vcard) { VCardigan.create }

    context '#name' do
      it 'should call method_missing with method n' do
        vcard.should_receive(:method_missing).with(:n)
        vcard.name
      end
    end
    
    context '#fullname' do
      it 'should call method_missing with method fn' do
        vcard.should_receive(:method_missing).with(:fn)
        vcard.fullname
      end
    end
  end

  describe '#to_s' do
    let(:vcard) { VCardigan.create }

    context 'with no FN' do
      it 'should raise an error' do
        expect { vcard.to_s }.to raise_error(VCardigan::EncodingError)
      end
    end

    context 'with an FN and N' do
      before do
        vcard.name('Strummer', 'Joe')
        vcard.fullname('Joe Strummer')
      end

      it 'should have BEGIN on first line' do
        vcard.to_s.split("\n").first.should == 'BEGIN:VCARD'
      end

      it 'should proceed with VERSION' do
        vcard.to_s.split("\n")[1].should == 'VERSION:4.0'
      end

      it 'should include the N field' do
        vcard.to_s.split("\n")[2].should == 'N:Strummer;Joe;;;'
      end

      it 'should include the FN field' do
        vcard.to_s.split("\n")[3].should == 'FN:Joe Strummer'
      end

      it 'should end with END' do
        vcard.to_s.split("\n").last.should == 'END:VCARD'
      end
    end
  end

  describe '#parse' do
    context 'valid 4.0 vCard' do
      let(:data) { File.read(File.dirname(__FILE__) + '/../helpers/joe.vcf') }
      let(:vcard) { VCardigan.parse(data) }
      let(:fields) { vcard.instance_variable_get(:@fields) }

      it 'should set the version' do
        vcard.version.should == '4.0'
      end

      it 'should add the properties to the fields array' do
        fields.should have_key('n')
        fields.should have_key('fn')
      end
    end

    context 'google 3.0 vCard' do
      let(:data) { File.read(File.dirname(__FILE__) + '/../helpers/google.vcf') }
      let(:vcard) { VCardigan.parse(data) }
      let(:fields) { vcard.instance_variable_get(:@fields) }

      it 'should set the version' do
        vcard.version.should == '3.0'
      end

      it 'should add the properties to the fields array' do
        fields.should have_key('n')
        fields.should have_key('fn')
        fields.should have_key('photo')
        fields.should have_key('x-socialprofile')
      end
    end
  end
end
