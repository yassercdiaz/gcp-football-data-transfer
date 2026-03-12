-- Staging model: Clean raw club data

with source as (
    
    select * from {{ source('football_raw', 'clubs') }}

),

cleaned as (

    select
        -- Primary identifiers
        club_id,
        trim(name) as club_name,
        club_code,
        domestic_competition_id,
        
        -- Stadium information
        trim(stadium_name) as stadium_name,
        stadium_seats,
        
        -- Squad metrics
        squad_size,
        round(average_age, 1) as average_age,
        
        -- Internationalization
        foreigners_number,
        round(foreigners_percentage, 1) as foreigners_percentage,
        national_team_players,
        
        -- Transfer balance (cleaned to numeric)
        case
            when regexp_contains(net_transfer_record, r'm$') then
                safe_cast(
                    regexp_replace(regexp_replace(net_transfer_record, r'[+€]', ''), r'm$', '') 
                    as float64
                ) * 1000000
            when regexp_contains(net_transfer_record, r'k$') then
                safe_cast(
                    regexp_replace(regexp_replace(net_transfer_record, r'[+€]', ''), r'k$', '') 
                    as float64
                ) * 1000
            when net_transfer_record = '+-0' then 0.0
            else null
        end as net_transfer_balance,
        
        -- Calculated field
        case 
            when squad_size > 0 and stadium_seats is not null 
            then round(stadium_seats / squad_size, 0)
            else null
        end as seats_per_player,
        
        -- Metadata
        last_season,
        url

    from source
    where name is not null

)

select * from cleaned