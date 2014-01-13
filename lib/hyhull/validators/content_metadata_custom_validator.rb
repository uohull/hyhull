class ContentMetadataCustomValidator < ActiveModel::Validator
  # This custom validate is used to validate that the Sequences are set correctly in the Content metadata i.e. three assets should have an
  # array with ["1", "2", "3"] (in any order)
  def validate(record)
    sequences = record.sequence
    unless sequences.empty?
      # Will populate valid_sequence_array with expected values based upon sequences size (i.e sequences size of two should have ["1", "2"])
      valid_sequence_array = ("1"..sequences.size.to_s).to_a  
      missing_sequences = valid_sequence_array - sequences
      unless missing_sequences.empty?
        record.errors[:sequence] << "#{missing_sequences.to_sentence} is missing."
      end
    end  
  end  
end