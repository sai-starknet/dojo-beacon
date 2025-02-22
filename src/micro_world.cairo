trait StaticModelBeacon<T, M> {
    const SELECTOR: felt252;
    fn set_model(ref self: T, model: @M);
    fn update_model(ref self: T, model: @M);
    fn update_member(ref self: T, model: @M);
}

#[starknet::contract]
mod beacon {
    use dojo_beacon::{
        owners_component, resource_component, resource_component::{BeaconEvents, ResourceWriter},
        writers_component,
    };

    use super::IBeacon;
    component!(path: resource_component, storage: resource, event: ResourceEvents);

    #[storage]
    struct Storage {
        #[substorage(v0)]
        resource: resource_component::Storage,
    }

    #[constructor]
    fn constructor(ref self: ContractState) {}

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        OwnersEvents: owners_component::Event,
        #[flat]
        ResourceEvents: resource_component::Event,
        #[flat]
        WritersEvents: writers_component::Event,
    }

    #[abi(embed_v0)]
    impl IResourse = resource_component::BeaconRegister<ContractState>;

    #[abi(embed_v0)]
    impl IOwners = owners_component::BeaconOwners<ContractState>;

    #[abi(embed_v0)]
    impl IWriters = writers_component::BeaconWriters<ContractState>;

    #[abi(embed_v0)]
    impl IBeaconImpl of IBeacon<ContractState> {
        fn set_model(
            ref self: ContractState,
            selector: felt252,
            entity_id: felt252,
            keys: Span<felt252>,
            values: Span<felt252>,
        ) {
            self.resource.assert_caller_is_model_writer_from_selector(selector);
            self.resource.emit_set_record(selector, entity_id, keys, values);
        }

        fn update_model(
            ref self: ContractState, selector: felt252, entity_id: felt252, values: Span<felt252>,
        ) {
            self.resource.assert_caller_is_model_writer_from_selector(selector);
            self.resource.emit_update_record(selector, entity_id, values);
        }

        fn update_member(
            ref self: ContractState,
            selector: felt252,
            entity_id: felt252,
            member_selector: felt252,
            values: Span<felt252>,
        ) {
            self.resource.assert_caller_is_model_writer_from_selector(selector);
            self.resource.emit_update_member(selector, entity_id, member_selector, values);
        }
    }
}
