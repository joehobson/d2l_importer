require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe D2lImporter::Converter do
  it 'should exist' do
    expect(D2lImporter::Converter).not_to be_nil
    expect(D2lImporter::Converter).to be < Canvas::Migration::Migrator
  end

  it "is a Canvas LMS class" do
    expect(D2lImporter::Converter).to be < Canvas::Migration::Migrator
  end

  before do
    Rails.application =
      Class.new do
        def self.config
          Class.new do
            def self.root
              Pathname.new(File.path(__dir__))
            end
          end
        end
      end
  end

  it 'should initalize' do
    settings = {archive_file: File.new('/dev/null')}
    expect{ D2lImporter::Converter.new(settings) }.not_to raise_error
  end

  it 'should require some settings' do
    settings = {}
    expect{ D2lImporter::Converter.new(settings) }.to raise_error RuntimeError
  end

  context "#export" do
    let(:archive_file) { File.new(File.expand_path(File.dirname(__FILE__))+ '/fixtures/D2LExport.zip') }
    subject { D2lImporter::Converter.new({archive_file: archive_file}) }
    it "should export a course hash" do
      expect{subject.export}.not_to raise_error
      expect(subject.course).to be_a Hash
      expect(subject.resources).not_to be_nil
      expect(subject.resources).to be_a Hash
      subject.resources.each do |resource_key, resource|
        expect(resource).to include :type, :material_type, :href, :migration_id
      end
      expect(subject.course[:modules]).to be_an Array
      expect(subject.course[:file_map]).to be_a Hash
      expect(subject.course[:all_files_zip]).to be_a String
      expect(File.exist? subject.course[:all_files_zip]).to be_truthy
      expect(subject.course[:wikis]).to be_an Array
      expect(subject.course[:discussion_topics]).to be_an Array
      expect(subject.course[:assessments]).to be_a Hash
      expect(subject.course[:assessments][:assessments]).to be_an Array
      subject.course[:assessments][:assessments].each do |assessment|
        expect(assessment.keys).to include 'migration_id', 'title', 'questions'
        # Assignment migration id causes problems because there's no assignments yet.
        expect(assessment.keys).not_to include 'assignment_migration_id'
      end
      expect(subject.course[:assessment_questions]).to be_a Hash
      expect(subject.course[:assessment_questions][:assessment_questions]).to be_an Array
      expect(subject.course[:assessment_questions][:assessment_questions].first).to be_a Hash
      expect(subject.course[:assessment_questions]).not_to be_empty
      expect(subject.course[:assignments]).to be_an Array
      expect(subject.course[:assignments].first).to be_a Hash
      expect(subject.course[:assignments].count).to be == 17
    end
  end
end
