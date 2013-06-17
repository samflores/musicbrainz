# -*- encoding: utf-8 -*-

require "spec_helper"

describe MusicBrainz::ReleaseGroup do
  describe '.search' do
    context 'without type filter' do
      it "searches release group by artist name and title" do
        expected = { artist_name: 'Kasabian', title: 'Empire' }
        
        MusicBrainz::Client.any_instance.should_receive(:search).with(
          described_class.to_s, %Q{artist:"#{expected[:artist_name]}" AND releasegroup:"#{expected[:title]}"}, create_models: false
        )
        
        described_class.search(expected[:artist_name], expected[:title])
      end
    end
    
    context 'with type filter' do
      it "searches album release group by artist name and title" do
        expected = { artist_name: 'Kasabian', title: 'Empire', type: 'Album' }
        
        MusicBrainz::Client.any_instance.should_receive(:search).with(
          described_class.to_s, %Q{artist:"#{expected[:artist_name]}" AND releasegroup:"#{expected[:title]}" AND type: #{expected[:type]}}, 
          create_models: false
        )
        
        described_class.search(expected[:artist_name], expected[:title], type: expected[:type])
      end
    end
  end
  
  describe '.find_by_artist_and_title' do
    it "gets first release group by artist name and title" do
      expected = { artist_name: 'Kasabian', title: 'Empire', id: 'xyz' }
      
      MusicBrainz::ReleaseGroup.should_receive(:search).with(expected[:artist_name], expected[:title], {}).and_return([{ id: expected[:id] }])
      MusicBrainz::ReleaseGroup.should_receive(:find).with(expected[:id])
      
      described_class.find_by_artist_and_title(expected[:artist_name], expected[:title])
    end
  end
  
  describe '.find_by_artist_id' do
    it 'gets the release groups for the artist with the given mbid' do
      MusicBrainz::Artist.any_instance.should_receive(:release_groups).once
      described_class.find_by_artist_id('69b39eab-6577-46a4-a9f5-817839092033')
    end
  end
  
  describe '#releases' do
    context 'releases already set' do
      it 'returns the cached releases' do
        release_group = described_class.new(id: '2225dd4c-ae9a-403b-8ea0-9e05014c778f')
        release_group.releases = [MusicBrainz::Release.new]
        
        MusicBrainz::Client.any_instance.should_not_receive(:search)
        
        release_group.releases
      end 
    end
    
    context 'releases not set yet' do
      it 'queries releases' do
        id = '2225dd4c-ae9a-403b-8ea0-9e05014c778f'
        
        MusicBrainz::Client.any_instance.should_receive(:search).with(
          'MusicBrainz::Release', { release_group: id, inc: [:media, :release_groups] }, sort: :date
        )
        
        described_class.new(id: id).releases
      end
    end
  end
end
