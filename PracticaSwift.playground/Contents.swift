/// GESTIÓN DE RESERVAS DE "HOTEL LUCHADORES"
/// Desarrollo de un sistema para gestionar reservas de hotel
/// Por Carlos Cano Alonso

import Foundation

// 1. Creamos las estructuras necesarias:
struct Client {
    let name: String
    let age: Int
    let height: Int
}
struct Reservation {
    let reservationID: Int
    let hotelName: String
    let clientData: [Client]
    let duration: Int
    let price: Float
    let hasBreakfast: Bool
}
enum ReservationError: Error {
    case sameID
    case clientDuplicated
    case reservationNotFound
}

// 2. Creamos la clase para la gestión de las reservas:
class HotelReservationManager {
    
    // 2.1. Creamos la lista de reservas y el contador para el ID único
    private var reservations: [Reservation] = []
    private var reservationIDCounter = 0
    
    // 2.2. Creamos el método para añadir nuevas reservas
    func addReservation (clientData: [Client], duration: Int, hasBreakfast: Bool) throws -> Reservation {
        
        // 2.2.1. Comprobamos que no haya clientes duplicados ni ID duplicado. Si lo hay, lanzamos el error correspondiente
        var clientDuplicated: Bool = false
        
        for clientCurrent in clientData {
            for reservation in reservations {
                if reservation.reservationID == reservationIDCounter { throw ReservationError.sameID }
                for clientTmp in reservation.clientData {
                    if clientCurrent.name == clientTmp.name {
                        clientDuplicated = true
                        break
                    }
                }
                if clientDuplicated { break }
            }
            if clientDuplicated { break }
        }
        if clientDuplicated { throw ReservationError.clientDuplicated }
        
        // 2.2.2. Calculamos el precio de la reserva
        let pricePerClient: Float = 20.00
        let breakfastYesNo: Float = hasBreakfast ? 1.25 : 1.00
        var price: Float = Float(clientData.count) * pricePerClient * breakfastYesNo * Float(duration)
        
        // 2.2.3. Añadimos la reserva a la lista de reservas y aumentamos el contador del ID
        let hotelName = "Hotel Luchadores"
        
        var newReservation = Reservation(reservationID: reservationIDCounter, hotelName: hotelName,
                                         clientData: clientData, duration: duration, price: price,
                                         hasBreakfast: hasBreakfast)
        reservations.append(newReservation)
        reservationIDCounter += 1
        
        // 2.2.4. Devolvemos la reserva
        return newReservation
    }
    
    // 3. Creamos el método para cancelar una reserva
    func cancelReservation(reservationID: Int) throws {
        
        // Verificamos que el ID de la reserva existe. Si no existe, lanzamos el error
        var found: Bool = false
        
        for cancelation in 0...reservations.count - 1 {
            if reservations[cancelation].reservationID == reservationID {
                reservations.remove(at: cancelation)
                found = true
                break
            }
        }
        if found == false { throw ReservationError.reservationNotFound }
    }
    
    // 4. Creamos el método para obtener las reservas actuales
    func currentReservations() -> [Reservation] {
        return reservations
    }
}

/// ------------------- TEST -------------------

// 1. Test para añadir nuevas reservas
func testAddReservation() {
    let manager = HotelReservationManager()
    
    // Creamos tres clientes
    let client1 = Client(name: "Goku", age: 35, height: 180)
    let client2 = Client(name: "Vegeta", age: 45, height: 170)
    let client3 = Client(name: "Bulma", age: 25, height: 160)
    
    do {
        // Creamos dos reservas, una con dos clientes y otra con un cliente
        let reservation1 = try manager.addReservation(clientData: [client1,client2], duration: 2, hasBreakfast: true)
        let reservation2 = try manager.addReservation(clientData: [client3], duration: 3, hasBreakfast: false)
        
        // Comprobamos que se están añadiendo correctamente las dos reservas y verificamos algunos campos
        assert(manager.currentReservations().count == 2, "No se están agregando reservas")
        
        assert(manager.currentReservations()[0].reservationID == 0, "No está añadiendo el ID")
        assert(manager.currentReservations()[0].hotelName == "Hotel Luchadores", "No se está añadiendo el hotel")
        assert(manager.currentReservations()[1].duration == 3, "No se están añadiendo los dìas")
        assert(manager.currentReservations()[1].hasBreakfast == false, "No se está añadiendo el desayuno")
        
        // Comprobamos que entra en el catch y lanza error al agregar otra reserva con un cliente que ya tiene una reserva
        let reservation3 = try manager.addReservation(clientData: [client3], duration: 4, hasBreakfast: true)
        assertionFailure("No se están detectando los clientes duplicados")
        
    } catch {
        print("Test error OK:", error)
    }
}

// 2. Test para cancelar reservas
func testCancelReservation() {
    let manager = HotelReservationManager()
    
    // Creamos cuatro clientes
    let client1 = Client(name: "Krilin", age: 30, height: 180)
    let client2 = Client(name: "Bulma", age: 25, height: 160)
    let client3 = Client(name: "Goku", age: 35, height: 180)
    let client4 = Client(name: "Vegeta", age: 45, height: 170)
    
    do {
        // Creamos tres reservas
        let reservation1 = try manager.addReservation(clientData: [client1], duration: 2, hasBreakfast: true)
        let reservation2 = try manager.addReservation(clientData: [client2], duration: 3, hasBreakfast: false)
        let reservation3 = try manager.addReservation(clientData: [client3, client4], duration: 4, hasBreakfast: true)
        
        // Cancelamos dos de las tres reservas existentes
        try manager.cancelReservation(reservationID: reservation1.reservationID)
        try manager.cancelReservation(reservationID: reservation3.reservationID)
        
        // Comprobamos que queda una reserva registrada y que se mantiene la que no ha sido eliminada
        assert(manager.currentReservations().count == 1, "No se están eliminando las reservas")
        assert(manager.currentReservations()[0].reservationID == 1, "No se está eliminado la reserva correcta")
        
        // Comprobamos que entra en el catch y lanza error de reserva no encontrada porque ya ha sido eliminada
        try manager.cancelReservation(reservationID: reservation1.reservationID)
        assertionFailure("No se están detectando reservas inexistentes")
        
    } catch {
        print("Test error OK:", error)
    }
}

// 3. Test para verificar el cálculo de precios
func testReservationPrice() {
    let manager = HotelReservationManager()
    
    // Creamos cuatro clientes
    let client1 = Client(name: "Goku", age: 35, height: 180)
    let client2 = Client(name: "Vegeta", age: 45, height: 170)
    let client3 = Client(name: "Bulma", age: 25, height: 160)
    let client4 = Client(name: "Krilin", age: 30, height: 180)
    
    do {
        // Creamos dos reservas
        let reservation1 = try manager.addReservation(clientData: [client1, client2], duration: 2, hasBreakfast: true)
        let reservation2 = try manager.addReservation(clientData: [client3, client4], duration: 2, hasBreakfast: true)
        
        // Verificamos que los precios coinciden en ambas reservas y se calculan correctamente
        assert(manager.currentReservations()[0].price == 100, "No se está añadiendo el precio correcto")
        assert(manager.currentReservations()[0].price == manager.currentReservations()[1].price, "Los precios no coinciden")
        
    } catch {
        print("Test error OK:", error)
    }
}

// Ejecutamos las funciones de los test
testAddReservation()
testCancelReservation()
testReservationPrice()
