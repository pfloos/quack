subroutine unrestricted_lda_correlation_energy(DFA,nEns,wEns,nGrid,weight,rho,Ec)

! Select the unrestrited version of the LDA correlation functional

  implicit none
  include 'parameters.h'

! Input variables

  character(len=12),intent(in)  :: DFA
  integer,intent(in)            :: nEns
  double precision,intent(in)   :: wEns(nEns)
  integer,intent(in)            :: nGrid
  double precision,intent(in)   :: weight(nGrid)
  double precision,intent(in)   :: rho(nGrid,nspin)

! Output variables

  double precision,intent(out)  :: Ec(nsp)

! Select correlation functional

  select case (DFA)

!   Hartree-Fock

    case ('HF')

      Ec(:) = 0d0

    case ('W38')

      call UW38_lda_correlation_energy(nGrid,weight,rho,Ec)

    case ('PW92')

      call UPW92_lda_correlation_energy(nGrid,weight,rho,Ec)

    case ('VWN3')

      call UVWN3_lda_correlation_energy(nGrid,weight,rho,Ec)

    case ('VWN5')

      call UVWN5_lda_correlation_energy(nGrid,weight,rho,Ec)

    case ('C16')

      call UC16_lda_correlation_energy(nGrid,weight,rho,Ec)

    case default

      call print_warning('!!! LDA correlation functional not available !!!')
      stop

  end select

end subroutine unrestricted_lda_correlation_energy
