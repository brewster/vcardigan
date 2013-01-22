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

end
