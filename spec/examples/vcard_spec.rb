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

end
